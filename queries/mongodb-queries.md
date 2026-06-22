# Requêtes MongoDB - CityFlow

Connexion au shell :
```bash
docker exec -it cityflow-mongo mongosh -u admin -p cityflow2025 --authenticationDatabase admin
use cityflow
```

---

## US-M1 - Profil utilisateur + 10 derniers trajets

> En tant qu'utilisateur, je veux pouvoir consulter mon profil et l'historique de mes 10 derniers trajets.

### Requête 1a - Profil utilisateur

```js
db.users.findOne(
  { userId: "u001" },
  { _id: 0, userId: 1, firstName: 1, lastName: 1, email: 1, role: 1, preferences: 1, createdAt: 1 }
)
```

### Résultat attendu

```json
{
  "userId": "u001",
  "firstName": "Alice",
  "lastName": "Martin",
  "email": "alice.martin@cityflow.fr",
  "role": "passenger",
  "preferences": { "transport": ["vélo", "metro"], "notifications": true },
  "createdAt": "2024-01-15T00:00:00.000Z"
}
```

### Requête 1b - 10 derniers trajets

```js
db.trips.find(
  { userId: "u001" },
  { _id: 0, tripId: 1, date: 1, distance: 1, duration: 1, steps: 1, comment: 1, rating: 1 }
).sort({ date: -1 }).limit(10)
```

### Résultat attendu

```json
[
  { "tripId":"t028", "date":"2025-06-05", "distance":2.9,  "duration":14, "steps":[{"mode":"vélo","from":"Garibaldi","to":"Bellecour","duration":14}],                                                                    "comment":"Courte balade en vélo, parfait pour les petits trajets quotidiens.", "rating":4.6 },
  { "tripId":"t023", "date":"2025-05-12", "distance":8.0,  "duration":30, "steps":[{"mode":"covoiturage","from":"Perrache","to":"Mermoz","duration":30}],                                                                  "comment":"Romain conduit prudemment, très agréable.", "rating":4.7 },
  { "tripId":"t016", "date":"2025-03-12", "distance":3.7,  "duration":20, "steps":[{"mode":"vélo","from":"Croix-Rousse","to":"Brotteaux","duration":20}],                                                                  "comment":"Descente agréable depuis la Croix-Rousse. Vélo parfaitement entretenu.", "rating":4.4 },
  { "tripId":"t007", "date":"2025-01-20", "distance":12.1, "duration":40, "steps":[{"mode":"covoiturage","from":"Bellecour","to":"Mermoz","duration":40}],                                                                  "comment":"Conducteur rapide, trajet fluide sur le périphérique.", "rating":4.6 },
  { "tripId":"t001", "date":"2025-01-08", "distance":4.2,  "duration":22, "steps":[{"mode":"vélo","from":"Bellecour","to":"Perrache","duration":8},{"mode":"metro","from":"Perrache","to":"Part-Dieu","duration":14}],      "comment":"Trajet très rapide, le vélo était bien chargé.", "rating":4.5 }
]
```

**Concept illustré :** Requête avec projection, tri par date décroissante et `limit()`. L'index composé `{ userId: 1, date: -1 }` permet à MongoDB de satisfaire cette requête en un seul balayage d'index sans COLLSCAN.

---

## US-M2 - Véhicules d'un type dans un arrondissement

> En tant qu'administrateur, je veux lister tous les véhicules d'un type donné disponibles dans un arrondissement.

### Requête

```js
db.vehicles.find(
  { type: "vélo", district: "3ème arrondissement", status: "available" },
  { _id: 0, vehicleId: 1, brand: 1, model: 1, station: 1, batteryLevel: 1, status: 1 }
)
```

### Résultat attendu

```json
[
  { "vehicleId":"v003", "brand":"Nextbike", "model":"Urban", "station":"Part-Dieu", "batteryLevel":78, "status":"available" }
]
```

### Variante - tous les scooters disponibles (tous arrondissements)

```js
db.vehicles.find(
  { type: "scooter", status: "available" },
  { _id: 0, vehicleId: 1, district: 1, station: 1, batteryLevel: 1 }
).sort({ batteryLevel: -1 })
```

### Résultat attendu

```json
[
  { "vehicleId":"v008", "district":"2ème arrondissement", "station":"Confluence",    "batteryLevel":95 },
  { "vehicleId":"v013", "district":"7ème arrondissement", "station":"Gerland",       "batteryLevel":90 },
  { "vehicleId":"v009", "district":"3ème arrondissement", "station":"Saxe-Gambetta", "batteryLevel":81 },
  { "vehicleId":"v011", "district":"6ème arrondissement", "station":"Foch",          "batteryLevel":73 }
]
```

**Concept illustré :** Filtre multi-champs sur un index composé `{ type, district, status }`. MongoDB utilise l'index pour ne scanner que les documents correspondants - équivalent d'un `WHERE type = ? AND district = ? AND status = ?` optimisé.

---

## US-M3 - Statistiques agrégées

> En tant qu'analyste, je veux obtenir : nombre de trajets par jour, distance moyenne, top 5 conducteurs.

### Requête 3a - Nombre de trajets par jour

```js
db.trips.aggregate([
  {
    $group: {
      _id: { $dateToString: { format: "%Y-%m-%d", date: "$date" } },
      nbTrajets: { $sum: 1 }
    }
  },
  { $sort: { _id: 1 } },
  { $project: { _id: 0, jour: "$_id", nbTrajets: 1 } }
])
```

### Résultat attendu (extrait)

```json
[
  { "jour":"2025-01-08", "nbTrajets":2 },
  { "jour":"2025-01-09", "nbTrajets":1 },
  { "jour":"2025-01-10", "nbTrajets":1 },
  { "jour":"2025-01-12", "nbTrajets":1 },
  { "jour":"2025-02-03", "nbTrajets":2 },
  { "jour":"2025-04-02", "nbTrajets":2 },
  { "jour":"2025-05-28", "nbTrajets":1 }
]
```

### Requête 3b - Distance moyenne de tous les trajets

```js
db.trips.aggregate([
  {
    $group: {
      _id: null,
      distanceMoyenne: { $avg: "$distance" },
      distanceMin:     { $min: "$distance" },
      distanceMax:     { $max: "$distance" },
      totalTrajets:    { $sum: 1 }
    }
  },
  { $project: { _id: 0, distanceMoyenne: { $round: ["$distanceMoyenne", 2] }, distanceMin: 1, distanceMax: 1, totalTrajets: 1 } }
])
```

### Résultat attendu

```json
[
  { "distanceMoyenne": 5.79, "distanceMin": 1.8, "distanceMax": 12.1, "totalTrajets": 30 }
]
```

### Requête 3c - Top 5 conducteurs

```js
db.trips.aggregate([
  { $match: { driverId: { $exists: true, $ne: null } } },
  { $group: { _id: "$driverId", nbTrajets: { $sum: 1 }, noteMoyenne: { $avg: "$rating" } } },
  { $sort: { nbTrajets: -1 } },
  { $limit: 5 },
  {
    $lookup: {
      from: "users",
      localField: "_id",
      foreignField: "userId",
      as: "conducteur"
    }
  },
  { $unwind: "$conducteur" },
  {
    $project: {
      _id: 0,
      conducteurId: "$_id",
      nom: { $concat: ["$conducteur.firstName", " ", "$conducteur.lastName"] },
      nbTrajets: 1,
      noteMoyenne: { $round: ["$noteMoyenne", 2] }
    }
  }
])
```

### Résultat attendu

```json
[
  { "conducteurId":"u003", "nom":"Sophie Leclerc",  "nbTrajets":4, "noteMoyenne":4.95 },
  { "conducteurId":"u016", "nom":"Romain Lefebvre", "nbTrajets":3, "noteMoyenne":4.8  },
  { "conducteurId":"u008", "nom":"Nicolas Petit",   "nbTrajets":3, "noteMoyenne":4.87 },
  { "conducteurId":"u011", "nom":"Camille Blanc",   "nbTrajets":2, "noteMoyenne":5.0  },
  { "conducteurId":"u004", "nom":"Marc Dupont",     "nbTrajets":2, "noteMoyenne":4.3  }
]
```

**Concept illustré :** Pipeline d'agrégation en 5 étapes : `$match` pour filtrer les covoiturages, `$group` pour compter et calculer la note, `$sort`+`$limit` pour le top 5, `$lookup` pour enrichir avec les données utilisateur (jointure côté applicatif MongoDB), `$project` pour formater la sortie.

---

## US-M4 - Recherche full-text sur les commentaires

> En tant que développeur, je veux effectuer une recherche full-text sur les commentaires laissés après les trajets.

L'index texte est créé dans le seed :
```js
db.trips.createIndex({ comment: "text" })
```

### Requête - Recherche du mot "vélo"

```js
db.trips.find(
  { $text: { $search: "vélo" } },
  { _id: 0, tripId: 1, comment: 1, rating: 1, score: { $meta: "textScore" } }
).sort({ score: { $meta: "textScore" } })
```

### Résultat attendu

```json
[
  { "tripId":"t001", "comment":"Trajet très rapide, le vélo était bien chargé. Je recommande Bellecour.", "rating":4.5, "score":1.1 },
  { "tripId":"t006", "comment":"Belle balade à vélo dans la montée de la Croix-Rousse. Recommande le vélo.", "rating":4.2, "score":1.5 },
  { "tripId":"t008", "comment":"Super piste cyclable entre Jean Macé et Gerland, je recommande le vélo ici.", "rating":5.0, "score":1.1 },
  { "tripId":"t014", "comment":"Vélo en parfait état... je recommande cette combinaison vélo-métro.", "rating":4.7, "score":1.5 },
  { "tripId":"t018", "comment":"Vélo électrique très pratique, aucun effort dans les côtes.", "rating":4.9, "score":1.1 },
  { "tripId":"t024", "comment":"Parfait pour une promenade matinale, vélo bien disponible à Bellecour.", "rating":4.8, "score":1.1 }
]
```

### Requête - Recherche multi-mots (OU logique)

```js
db.trips.find(
  { $text: { $search: "ponctuelle confortable" } },
  { _id: 0, tripId: 1, comment: 1, score: { $meta: "textScore" } }
).sort({ score: { $meta: "textScore" } })
```

### Résultat attendu

```json
[
  { "tripId":"t002", "comment":"Conductrice ponctuelle et véhicule propre. Très confortable.", "score":1.5 },
  { "tripId":"t009", "comment":"Très bon conducteur, voiture propre et confortable.",          "score":0.75 },
  { "tripId":"t017", "comment":"Sophie arrive toujours à l'heure. Voiture confortable.",        "score":0.75 }
]
```

**Concept illustré :** L'index `text` MongoDB tokenise et stemmatise le contenu de `comment`. L'opérateur `$text` fait une recherche plein texte avec score de pertinence (`textScore`). En SQL équivalent, cela nécessiterait `LIKE '%vélo%'` sans index (scan complet) ou une extension FTS (tsvector/tsquery sous PostgreSQL), nettement plus verbeux à configurer.
