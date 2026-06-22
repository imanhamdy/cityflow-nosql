# Modélisation MongoDB - CityFlow

## Pourquoi MongoDB pour ces données ?

MongoDB est choisi pour les **données métier riches** : profils utilisateurs, trajets multimodaux et véhicules disponibles. Ces données ont trois propriétés qui font de MongoDB le choix naturel :

1. **Schémas flexibles et évolutifs** - un trajet contient un nombre variable d'étapes (1 à n modes de transport), une voiture a des propriétés différentes d'un vélo (plaque, places, etc.). MongoDB gère nativement cette variabilité sans ALTER TABLE. *En tant qu'utilisateur, mon profil et mes trajets ont des structures hétérogènes que MongoDB absorbe sans contrainte de schéma.*
2. **Documents imbriqués** - les étapes d'un trajet sont toujours lues avec le trajet lui-même. L'embedding évite les jointures coûteuses. *En tant qu'utilisateur consultant mon historique (US-M1), tout est accessible en une seule lecture.*
3. **Requêtes ad-hoc** - *En tant qu'analyste, j'interroge les données selon des critères variés (par jour, par arrondissement, par type de véhicule) sans avoir à anticiper chaque requête dans le schéma.* MongoDB excelle pour ces requêtes exploratoires (US-M3).
4. **Index full-text natif** - *En tant que développeur, j'active la recherche sur les commentaires (US-M4) avec un simple index `text`, sans déployer une infrastructure externe comme Elasticsearch.*

---

## Collections

### `users` - Profils utilisateurs

```json
{
  "userId":    "u001",
  "firstName": "Alice",
  "lastName":  "Martin",
  "email":     "alice.martin@cityflow.fr",
  "phone":     "+33612345678",
  "role":      "passenger",
  "isVerified": true,
  "createdAt": "2024-01-15T00:00:00Z",
  "preferences": {
    "transport":      ["vélo", "metro"],
    "notifications":  true
  }
}
```

**Choix de modélisation :**
- `preferences` est **embeddé** - c'est une donnée intrinsèque à l'utilisateur, toujours lue en même temps que son profil, et ne dépassera jamais quelques champs.
- `userId` est un identifiant métier lisible (ex. `"u001"`) en plus de l'`_id` ObjectId, pour faciliter les références croisées dans les autres collections.

---

### `vehicles` - Véhicules disponibles

```json
{
  "vehicleId":       "v001",
  "type":            "vélo",
  "brand":           "Pony",
  "model":           "City e-Bike",
  "status":          "available",
  "district":        "1er arrondissement",
  "station":         "Bellecour",
  "batteryLevel":    92,
  "lastMaintenance": "2025-04-10T00:00:00Z"
}
```

**Choix de modélisation :**
- Collection indépendante (pas embeddée dans `users`) - un véhicule existe indépendamment de tout trajet, est partagé entre plusieurs utilisateurs, et est interrogé seul. *En tant qu'administrateur, je filtre les véhicules par type et arrondissement (US-M2) directement sur cette collection sans jointure.*
- `district` et `station` sont des strings plutôt que des références - les arrondissements/stations ne changent pas, il n'y a pas de collection `stations` à maintenir en cohérence (c'est Neo4j qui gère le graphe des stations).
- Pas de `lastUserId` : la gestion des réservations temps réel est confiée à Redis, pas MongoDB.

---

### `trips` - Trajets effectués

```json
{
  "tripId":   "t001",
  "userId":   "u001",
  "driverId": "u003",
  "vehicleId":"v014",
  "date":     "2025-01-08T08:30:00Z",
  "distance": 7.8,
  "duration": 35,
  "status":   "completed",
  "steps": [
    { "mode": "covoiturage", "from": "Perrache", "to": "Brotteaux", "duration": 35 }
  ],
  "comment": "Conductrice ponctuelle et véhicule propre. Très confortable.",
  "rating":   5.0
}
```

**Choix embed vs. référence :**

| Champ | Décision | Justification |
|---|---|---|
| `steps[]` | **Embeddé** | Un trajet et ses étapes sont toujours lus ensemble. L'embedding évite une collection `steps` qui ne serait jamais interrogée indépendamment. |
| `userId` | **Référence** | Un utilisateur possède de nombreux trajets ; stocker le profil complet dans chaque trajet créerait une redondance massive et des incohérences lors d'une mise à jour du profil. |
| `driverId` | **Référence** | Même logique. Présent uniquement pour les trajets en covoiturage. |
| `vehicleId` | **Référence** | Le véhicule est une entité indépendante dont l'état change. |
| `comment` | **Embeddé** | Le commentaire est propre au trajet, toujours lu avec lui, et c'est le champ cible de l'index full-text (US-M4). |

---

## Index définis

| Collection | Index | Type | User Story |
|---|---|---|---|
| `trips` | `{ userId: 1, date: -1 }` | Composé | US-M1 : derniers trajets triés par date |
| `vehicles` | `{ type: 1, district: 1, status: 1 }` | Composé | US-M2 : véhicules par type + arrondissement |
| `trips` | `{ date: 1 }` | Simple | US-M3 : agrégation par jour |
| `trips` | `{ driverId: 1 }` | Simple | US-M3 : top conducteurs |
| `trips` | `{ comment: "text" }` | Texte | US-M4 : recherche full-text |
| `users` | `{ userId: 1 }` | Unique | lookups transversaux |
| `vehicles` | `{ vehicleId: 1 }` | Unique | intégrité référentielle |

---

## Coût d'une base relationnelle unique

*En tant que développeur*, avec PostgreSQL à la place de MongoDB, les `steps[]` exigeraient une table `trip_steps(trip_id, seq, mode, from, to, duration)` avec JOIN systématique à chaque lecture de trajet. Les `preferences{}` nécessiteraient soit du JSON hétérogène, soit plusieurs colonnes nullables, rendant les migrations de schéma complexes. La recherche full-text sur `comment` serait faisable, mais moins intégrée que l'index `text` natif de MongoDB. *En tant qu'analyste*, chaque nouvelle dimension d'analyse (arrondissement, type de véhicule, eco-score) imposerait une migration de schéma SQL, là où MongoDB accepte de nouveaux champs sans interruption de service.
