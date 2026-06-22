# Modélisation Redis - CityFlow

## Pourquoi Redis pour ces données ?

Redis est choisi pour les données **temps réel et performance** de CityFlow pour trois raisons fondamentales :

1. **Latence sub-milliseconde** - la disponibilité des stations doit s'afficher en moins de 10 ms. Une requête MongoDB prendrait 20-50 ms, inacceptable pour une carte en temps réel mise à jour toutes les secondes.
2. **Expiration automatique (TTL)** - les disponibilités de stations, les sessions et les compteurs de rate limiting ont naturellement une durée de vie limitée. Redis gère cela nativement avec `EXPIRE`, sans job de nettoyage à écrire ni colonne `expires_at` à maintenir.
3. **Structures spécialisées** - un Sorted Set est la structure parfaite pour un classement : `ZREVRANGE` renvoie le top 10 en O(log N + K). En SQL, cela nécessiterait `SELECT userId, COUNT(*) ... ORDER BY ... LIMIT 10` avec un scan de table à chaque appel.

**Coût d'une approche SQL :** gérer le rate limiting avec une table `api_calls(userId, minute, count)` exige des transactions et des locks pour éviter les race conditions sur `UPDATE`. Redis gère l'atomicité de `INCR` nativement - pas de lock nécessaire.

---

## Convention de nommage

Pattern général : `{domaine}:{entite}:{identifiant}[:{attribut}]`

| Règle | Exemple |
|---|---|
| Séparateur `:` entre niveaux hiérarchiques | `station:S001:availability` |
| Domaine en premier (permet le scan par préfixe) | `session:`, `leaderboard:`, `ratelimit:` |
| Identifiant métier lisible | `u001`, `S001`, `2025-06` |
| Clé mensuelle avec `{YYYY-MM}` (rotation naturelle) | `leaderboard:monthly:2025-06` |

---

## Tableau du schéma de clés

| Clé (pattern) | Structure Redis | TTL | User Story | Commandes principales |
|---|---|---|---|---|
| `station:{id}:availability` | **Hash** | 300s démo / 60s prod | US-R1 | `HSET`, `HGETALL`, `HGET`, `EXPIRE` |
| `session:{token}` | **Hash** | 1800s (sliding) | US-R2 | `HSET`, `HGETALL`, `EXISTS`, `EXPIRE`, `DEL` |
| `leaderboard:monthly:{YYYY-MM}` | **Sorted Set** | aucun | US-R3 | `ZADD`, `ZREVRANGE`, `ZINCRBY`, `ZREVRANK`, `ZSCORE` |
| `ratelimit:user:{userId}` | **String** (compteur) | 60s | US-R4 | `INCR`, `EXPIRE`, `GET` |
| `notifications:{userId}` | **List** | 86400s | Bonus | `RPUSH`, `LRANGE`, `LTRIM` |
| `user:{userId}:tags` | **Set** | aucun | Bonus | `SADD`, `SMEMBERS`, `SISMEMBER` |

---

## Détail par structure

### Hash - `station:{id}:availability`

Champs stockés :
```
name        "Bellecour"
district    "1er arrondissement"
bikes       8
scooters    3
capacity    20
```

**Pourquoi Hash ?** Chaque station est une entité avec plusieurs propriétés. Le Hash permet de lire un seul champ (`HGET station:S001:availability bikes`) ou tous (`HGETALL`) sans désérialiser un JSON. C'est plus efficace qu'un String JSON pour des accès partiels fréquents.

**TTL 60s (production) :** Les capteurs IoT actualisent la disponibilité toutes les minutes. Une valeur expirée (cache miss) déclenche une requête vers la source de vérité (MongoDB) et une réinsertion dans Redis.

---

### Hash - `session:{token}`

Champs stockés :
```
userId       "u001"
firstName    "Alice"
lastName     "Martin"
email        "alice.martin@cityflow.fr"
role         "passenger"
createdAt    "2025-06-21T08:30:00Z"
lastAction   "2025-06-21T09:00:00Z"
```

**Pourquoi Hash ?** La session regroupe plusieurs champs lus ensemble à chaque requête HTTP. Le TTL sliding (renouvelé à chaque `EXPIRE` sur action) correspond exactement au comportement "session inactive depuis 30 min = expirée" demandé par US-R2.

---

### Sorted Set - `leaderboard:monthly:{YYYY-MM}`

Membres : `userId` (ex. `u001`, `u003`)
Score : nombre de trajets du mois

**Pourquoi Sorted Set ?** C'est la structure native pour un classement ordonné. Le tri est maintenu automatiquement à chaque `ZADD`/`ZINCRBY`. `ZREVRANGE 0 9` retourne le top 10 en une commande, en O(log N + K).

**Clé mensuelle :** en fin de mois, la couche applicative crée une nouvelle clé `leaderboard:monthly:2025-07` et archive ou supprime l'ancienne. Aucun `UPDATE` SQL complexe.

---

### String - `ratelimit:user:{userId}`

Valeur : entier (nombre de requêtes dans la minute courante)
TTL : 60s (expire naturellement à la fin de la minute, la clé repart à 0)

**Pourquoi String ?** `INCR` est atomique : même sous charge concurrente, deux requêtes simultanées n'incrémentent jamais le même compteur de façon incorrecte. Impossible à garantir aussi simplement avec une table SQL sans transaction explicite.

---

### List - `notifications:{userId}` (Bonus)

Eléments : JSON string par notification (type, message, timestamp)
Ordre : chronologique (RPUSH = ajout en queue)

**Pourquoi List ?** L'accès est toujours "les N dernières notifications". `LRANGE 0 2` renvoie les 3 premières, `LTRIM 0 9` limite la taille à 10 éléments sans job de nettoyage.

---

### Set - `user:{userId}:tags` (Bonus)

Membres : chaînes de tags (`"premium"`, `"eco-friendly"`, `"top-driver"`)

**Pourquoi Set ?** L'unicité est garantie nativement. `SISMEMBER` vérifie un tag en O(1). Des opérations comme `SINTER` permettraient de trouver les utilisateurs à la fois `premium` et `top-driver` sans requête SQL complexe.
