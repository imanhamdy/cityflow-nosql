# Requêtes Redis - CityFlow

Connexion au shell :
```bash
docker exec -it cityflow-redis redis-cli --no-auth-warning -a cityflow2025
```

---

## US-R1 - Disponibilité en temps réel d'une station

> En tant qu'utilisateur, je veux voir en temps réel combien de vélos sont disponibles à la station X.

### Cas 1 - Cache hit (clé présente)

```bash
# Lire toutes les disponibilités de la station Bellecour
HGETALL station:S001:availability
```

**Résultat attendu :**
```
1) "name"
2) "Bellecour"
3) "district"
4) "1er arrondissement"
5) "bikes"
6) "8"
7) "scooters"
8) "3"
9) "capacity"
10) "20"
```

```bash
# Lire uniquement le nombre de vélos (accès partiel optimisé)
HGET station:S001:availability bikes
```

**Résultat attendu :** `"8"`

```bash
# Vérifier le TTL restant (combien de secondes avant expiration)
TTL station:S001:availability
```

**Résultat attendu :** `247` *(valeur décroissante)*

### Cas 2 - Cache miss (clé expirée ou inconnue)

```bash
TTL station:S099:availability
```

**Résultat attendu :** `-2` *(clé inexistante = cache miss)*

Dans ce cas, l'application :
1. Interroge MongoDB pour lire la disponibilité depuis la collection `vehicles`
2. Réinsère la valeur dans Redis avec un nouveau TTL

```bash
# Réalimentation du cache après miss
HSET station:S099:availability name "NouvelleStation" district "2eme arrondissement" bikes 5 scooters 2 capacity 12
EXPIRE station:S099:availability 300
```

### Mise à jour par capteur IoT (simulation)

```bash
# Le capteur de Bellecour signale qu'un vélo vient d'être pris
HSET station:S001:availability bikes 7
# Renouveler le TTL (le capteur confirme que la donnée est fraîche)
EXPIRE station:S001:availability 300
```

**Concept illustré :** Pattern Cache-Aside avec TTL automatique. Redis sert de cache devant MongoDB. La latence de lecture passe de ~30ms (MongoDB) à <1ms (Redis). Le TTL garantit que les données ne restent jamais périmées plus de 60s en production sans intervention manuelle.

---

## US-R2 - Session utilisateur avec expiration glissante de 30 minutes

> En tant qu'utilisateur, je veux que ma session reste active pendant 30 minutes après ma dernière action.

### Séquence complète à chaque requête HTTP

```bash
# Étape 1 - Vérifier que la session existe (token reçu dans le header HTTP)
EXISTS session:tok_u001_a1b2c3d4
```

**Résultat attendu :** `1` (existe) ou `0` (expirée → rediriger vers login)

```bash
# Étape 2 - Si elle existe, lire les données utilisateur
HGETALL session:tok_u001_a1b2c3d4
```

**Résultat attendu :**
```
1) "userId"
2) "u001"
3) "firstName"
4) "Alice"
5) "lastName"
6) "Martin"
7) "email"
8) "alice.martin@cityflow.fr"
9) "role"
10) "passenger"
11) "createdAt"
12) "2025-06-21T08:30:00Z"
13) "lastAction"
14) "2025-06-21T09:00:00Z"
```

```bash
# Étape 3 - Renouveler le TTL (sliding expiration : 30 min depuis MAINTENANT)
EXPIRE session:tok_u001_a1b2c3d4 1800
```

**Résultat attendu :** `1` *(TTL appliqué avec succès)*

```bash
# Vérification : le TTL est bien remis à 1800
TTL session:tok_u001_a1b2c3d4
```

**Résultat attendu :** `1800`

### Mise à jour du champ lastAction

```bash
HSET session:tok_u001_a1b2c3d4 lastAction 2025-06-21T09:15:00Z
EXPIRE session:tok_u001_a1b2c3d4 1800
```

### Déconnexion (suppression de la session)

```bash
DEL session:tok_u001_a1b2c3d4
```

**Résultat attendu :** `1` *(1 clé supprimée)*

**Concept illustré :** Le sliding TTL (`EXPIRE` répété à chaque action) simule exactement une "inactivité de 30 min". Sans Redis, implémenter ce comportement en SQL nécessiterait une table `sessions`, un `UPDATE last_activity` à chaque requête, et un job cron pour purger les sessions expirées. Redis remplace tout cela par une seule commande atomique.

---

## US-R3 - Classement des 10 utilisateurs les plus actifs du mois

> En tant qu'utilisateur, je veux consulter le classement des 10 utilisateurs les plus actifs du mois.

### Requête principale - Top 10 avec scores

```bash
ZREVRANGE leaderboard:monthly:2025-06 0 9 WITHSCORES
```

**Résultat attendu :**
```
 1) "u001"   2) "28"
 3) "u003"   4) "25"
 5) "u008"   6) "22"
 7) "u016"   8) "20"
 9) "u011"  10) "18"
11) "u004"  12) "15"
13) "u012"  14) "14"
15) "u007"  16) "12"
17) "u014"  18) "11"
19) "u002"  20) "10"
```

### Rang d'un utilisateur spécifique

```bash
# Rang de u001 dans le classement (0 = premier)
ZREVRANK leaderboard:monthly:2025-06 u001
```

**Résultat attendu :** `0`

```bash
# Score d'un utilisateur
ZSCORE leaderboard:monthly:2025-06 u008
```

**Résultat attendu :** `"22"`

### Incrémenter le score après un trajet (mise à jour temps réel)

```bash
# Alice vient de terminer un trajet → +1 point
ZINCRBY leaderboard:monthly:2025-06 1 u001
```

**Résultat attendu :** `"29"` *(nouveau score)*

### Nombre total de participants au classement

```bash
ZCARD leaderboard:monthly:2025-06
```

**Résultat attendu :** `20`

**Concept illustré :** Le Sorted Set maintient l'ordre automatiquement à chaque `ZINCRBY`. Récupérer le top 10 est une opération O(log N + 10) quelle que soit la taille du classement. En base relationnelle, chaque lecture du leaderboard nécessite un `COUNT(*) GROUP BY userId ORDER BY` sur la table de trajets - potentiellement des millions de lignes à agréger pour un résultat affiché en temps réel.

---

## US-R4 - Rate limiting à 100 requêtes par minute

> En tant que système, je veux limiter chaque utilisateur à 100 requêtes API par minute.

### Séquence à chaque requête API reçue

```bash
# Étape 1 - Incrémenter le compteur atomiquement
INCR ratelimit:user:u009
```

**Résultat attendu :** `94` *(valeur après incrément)*

```bash
# Étape 2 - Si c'est le premier incrément (valeur = 1), fixer le TTL
# (TTL = -1 signifie "pas de TTL", donc première requête de la minute)
TTL ratelimit:user:u009
```

**Résultat attendu :** `45` *(TTL déjà fixé depuis une requête précédente)*

```bash
# Si TTL retourne -1 (nouvelle clé sans TTL) :
# EXPIRE ratelimit:user:u009 60
```

```bash
# Étape 3 - Vérifier le seuil
GET ratelimit:user:u009
```

**Résultat attendu :** `"94"` → 94 < 100 → **requête autorisée**

### Cas de dépassement du seuil

```bash
# Simulation : u009 atteint 101 requêtes
SET ratelimit:user:u009 101 KEEPTTL

INCR ratelimit:user:u009
# → 102

GET ratelimit:user:u009
# → "102" → 102 > 100 → HTTP 429 Too Many Requests
```

### Vérifier l'état des 3 utilisateurs seedés

```bash
GET ratelimit:user:u002
# → "47"  (modéré, TTL ~60s)

GET ratelimit:user:u009
# → "93"  (proche du seuil, TTL ~45s)

GET ratelimit:user:u013
# → "12"  (faible, TTL ~30s)
```

### Séquence atomique recommandée (production)

En production, les étapes INCR + EXPIRE se font en une transaction Lua ou avec `SET NX` pour éviter la race condition entre deux processus :

```bash
# Option pipeline atomique
MULTI
INCR ratelimit:user:u009
EXPIRE ratelimit:user:u009 60
EXEC
```

**Concept illustré :** `INCR` est une opération atomique dans Redis - même si 1000 requêtes arrivent simultanément pour le même utilisateur, chaque `INCR` est sérialisé correctement. Le TTL de 60s expire automatiquement la clé, remettant le compteur à zéro pour la minute suivante sans aucun job de nettoyage.
