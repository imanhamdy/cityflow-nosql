# Requêtes Cassandra - CityFlow

## Connexion

```bash
docker exec -it cityflow-cassandra cqlsh -u cassandra -p cassandra
```

Une fois dans cqlsh :

```sql
USE cityflow;
```

## Vérifications après import

```sql
DESCRIBE KEYSPACES;
USE cityflow;
DESCRIBE TABLES;

SELECT COUNT(*) FROM station_passages;
SELECT COUNT(*) FROM user_connexions;
SELECT * FROM daily_station_stats WHERE station_id = 'S001';
```

Résultat attendu :

```text
station_passages : 200 lignes
user_connexions  : 200 lignes
daily_station_stats : statistiques par jour pour S001
```

---

## US-C1 - Historique des passages d'une station sur une période

### Besoin

En tant qu'analyste, je veux retrouver l'historique des passages d'une station spécifique sur une période donnée.

### Requête pour une journée

```sql
SELECT event_time, event_id, user_id, event_type, vehicle_type
FROM station_passages
WHERE station_id = 'S001'
AND day = '2025-09-15'
AND event_time >= '2025-09-15 07:00:00+0000'
AND event_time <= '2025-09-15 20:00:00+0000';
```

### Requête sur plusieurs jours

La partition est `(station_id, day)`. Cassandra ne permet pas de faire un range efficace sur plusieurs partitions. L'application exécute donc une requête par jour.

```sql
SELECT event_time, event_id, user_id, event_type, vehicle_type
FROM station_passages
WHERE station_id = 'S001'
AND day = '2025-09-15';

SELECT event_time, event_id, user_id, event_type, vehicle_type
FROM station_passages
WHERE station_id = 'S001'
AND day = '2025-09-16';

SELECT event_time, event_id, user_id, event_type, vehicle_type
FROM station_passages
WHERE station_id = 'S001'
AND day = '2025-09-17';
```

**Concept démontré :** Cette requête démontre le modèle query-first de Cassandra. La Partition Key composée `(station_id, day)` garantit que tous les événements d'une station pour un jour donné sont co-localisés sur le même noeud, rendant la lecture en O(1) sans scan global. Le Clustering Order `event_time DESC` rend les événements les plus récents accessibles en tête de partition sans tri supplémentaire.

---

## US-C2 - Enregistrer plusieurs milliers d'événements par minute

### Besoin

En tant que système, je veux pouvoir enregistrer plusieurs milliers d'événements de passage par minute sans dégradation.

### Écriture d'un nouvel événement

```sql
BEGIN BATCH
INSERT INTO station_passages (
  station_id, day, event_time, event_id, user_id, event_type, vehicle_type
)
VALUES (
  'S001',
  '2025-09-22',
  '2025-09-22 08:30:00+0000',
  11111111-1111-1111-8111-111111111111,
  'user_001',
  'rent',
  'bike'
);

INSERT INTO user_connexions (
  user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type
)
VALUES (
  'user_001',
  '2025-09',
  '2025-09-22 08:30:00+0000',
  11111111-1111-1111-8111-111111111111,
  'S001',
  'Station République',
  'rent',
  'bike'
);
APPLY BATCH;
```

### Mise à jour du compteur

```sql
UPDATE daily_station_stats
SET total_events = total_events + 1,
    total_rents = total_rents + 1,
    total_returns = total_returns + 0
WHERE station_id = 'S001'
AND day = '2025-09-22';
```

**Concept démontré :** Cette requête démontre les écritures append-only de Cassandra. Chaque insertion est indépendante, sans verrou ni transaction distribuée. Le `BEGIN BATCH` ici garantit que les deux vues (`station_passages` et `user_connexions`) recoivent le même `event_id`, ce qui est acceptable en seed ; en production les insertions seraient pilotées par la couche applicative en parallèle sur chaque table.

---

## US-C3 - Connexions d'un utilisateur sur 30 jours

### Besoin

En tant qu'utilisateur, je veux consulter mes propres connexions des 30 derniers jours.

### Requête

```sql
SELECT event_time, event_id, station_id, station_name, event_type, vehicle_type
FROM user_connexions
WHERE user_id = 'user_001'
AND month = '2025-09'
AND event_time >= '2025-09-01 00:00:00+0000'
AND event_time <= '2025-09-30 23:59:59+0000';
```

Cette requête est efficace car elle cible une seule partition : `(user_id, month)`.

**Concept démontré :** Cette requête démontre la dénormalisation intentionnelle de Cassandra. Le même événement est stocké à la fois dans `station_passages` (vu par la station) et dans `user_connexions` (vu par l'utilisateur). Cette duplication est le prix à payer pour obtenir deux lectures en O(1) sans join - chaque partition est optimisée pour un seul pattern d'accès.

---

## US-C4 - Évolution journalière des passages

### Besoin

En tant qu'analyste, je veux obtenir l'évolution journalière du nombre de passages pour identifier les pics d'affluence.

### Requête pour une station

```sql
SELECT day, total_events, total_rents, total_returns
FROM daily_station_stats
WHERE station_id = 'S001';
```

### Requête pour un jour précis

```sql
SELECT day, total_events, total_rents, total_returns
FROM daily_station_stats
WHERE station_id = 'S001'
AND day = '2025-09-15';
```

**Concept démontré :** Cette requête démontre l'usage des colonnes COUNTER de Cassandra. Les statistiques sont calculées à l'écriture (chaque événement incrémente les compteurs) et non à la lecture - évitant ainsi un `COUNT(*) GROUP BY day` sur des millions de lignes. C'est un exemple de CQRS (Command Query Responsibility Segregation) appliqué au niveau de la base de données.

---

## Démo recommandée

```sql
USE cityflow;

SELECT COUNT(*) FROM station_passages;
SELECT COUNT(*) FROM user_connexions;

SELECT *
FROM station_passages
WHERE station_id = 'S001'
AND day = '2025-09-15';

SELECT *
FROM user_connexions
WHERE user_id = 'user_001'
AND month = '2025-09';

SELECT *
FROM daily_station_stats
WHERE station_id = 'S001';
```

## Points à expliquer pendant la démo

- Cassandra est utilisée pour les événements time-series.
- Les tables sont conçues selon les requêtes.
- La duplication des événements est volontaire.
- `replication_factor = 1` est uniquement pour le TP Docker.
- En production, CityFlow utiliserait `NetworkTopologyStrategy` avec un facteur de réplication de 3.
