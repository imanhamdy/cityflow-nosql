# Modélisation Cassandra - CityFlow

## 1. Rôle de Cassandra dans CityFlow

Dans l'architecture polyglotte CityFlow, Cassandra est utilisée pour les données massives et horodatées :

- historique des passages aux stations ;
- événements de location et de retour ;
- logs de connexions ou d'actions utilisateur ;
- statistiques journalières des passages.

Cassandra est choisie parce qu'elle est adaptée aux écritures massives, aux données time-series et à la scalabilité horizontale. Les besoins métier qui justifient ce choix sont portés par trois profils distincts : *l'analyste* qui veut retrouver l'historique d'une station, *le système* qui doit absorber des milliers d'événements par minute, et *l'utilisateur* qui consulte ses propres connexions.

## 2. Pourquoi Cassandra ?

### Pourquoi pas MongoDB ?

MongoDB est très adapté aux documents riches comme les profils utilisateurs, les trajets effectués ou les véhicules disponibles. En revanche, il est moins adapté qu'un modèle wide-column distribué pour absorber un volume très important d'événements horodatés en écriture continue.

### Pourquoi pas Redis ?

Redis est excellent pour le cache, les sessions, les disponibilités temps réel et les classements. Par contre, conserver un historique durable de millions d'événements dans Redis coûterait très cher en mémoire.

### Pourquoi pas Neo4j ?

Neo4j est idéal pour le réseau de transport, les relations entre stations et les calculs d'itinéraires. Les passages aux stations sont des événements time-series, ils ne nécessitent pas de traversée de graphe.

### Pourquoi Cassandra ?

Cassandra est adaptée car elle offre :

- **écriture très rapide** - *en tant que système, enregistrer plusieurs milliers d'événements de passage par minute (US-C2) sans dégradation des performances ;*
- **modèle time-series efficace** - *en tant qu'analyste, retrouver l'historique d'une station sur une période donnée (US-C1) en une lecture par partition ;*
- **partitionnement horizontal** - les données d'une station pour un jour sont isolées sur un nœud, les requêtes ne scannent jamais l'intégralité de la base ;
- **réplication native** - haute disponibilité sans point unique de défaillance dans un vrai cluster ;
- **colonnes COUNTER** - *en tant qu'analyste consultant l'évolution journalière des passages (US-C4), les compteurs sont maintenus à l'écriture, pas recalculés à la lecture.*

## 3. Keyspace

Dans le seed local :

```sql
CREATE KEYSPACE cityflow
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1}
AND durable_writes = true;
```

`replication_factor = 1` est volontaire pour Docker, car le TP tourne sur un seul conteneur Cassandra.

## 4. Architecture de production

En production, CityFlow n'utiliserait pas un seul noeud. Le keyspace serait plutôt créé ainsi :

```sql
CREATE KEYSPACE cityflow
WITH replication = {
  'class': 'NetworkTopologyStrategy',
  'datacenter_lyon': 3
};
```

Avec un niveau de cohérence comme `LOCAL_QUORUM`, CityFlow aurait un compromis équilibré entre disponibilité, tolérance aux pannes et cohérence.

## 5. Principe de modélisation

Cassandra ne se modélise pas comme une base SQL. Il n'y a pas de jointures. Le modèle est construit à partir des requêtes à supporter.

Pour cette raison, le même événement est volontairement dupliqué dans plusieurs tables :

- `station_passages`
- `user_connexions`

Cette dénormalisation permet de répondre rapidement à chaque user story.

## 6. Table `station_passages`

```sql
CREATE TABLE station_passages (
    station_id   TEXT,
    day          DATE,
    event_time   TIMESTAMP,
    event_id     TIMEUUID,
    user_id      TEXT,
    event_type   TEXT,
    vehicle_type TEXT,
    PRIMARY KEY ((station_id, day), event_time, event_id)
) WITH CLUSTERING ORDER BY (event_time DESC, event_id ASC);
```

### Objectif

*En tant qu'analyste*, retrouver l'historique des passages d'une station spécifique sur une période donnée (US-C1), sans scanner l'ensemble de la base.

### Choix de clé

La partition est :

```sql
(station_id, day)
```

Une partition correspond donc à une station pour une journée.

Avantages :

- évite les partitions trop grandes ;
- répartit les écritures ;
- permet de lire rapidement l'historique d'une station sur une journée.

Les colonnes de clustering sont :

```sql
event_time, event_id
```

`event_time DESC` permet d'afficher les événements les plus récents en premier.

`event_id TIMEUUID` garantit l'unicité et correspond mieux aux workloads time-series.

## 7. Table `user_connexions`

```sql
CREATE TABLE user_connexions (
    user_id      TEXT,
    month        TEXT,
    event_time   TIMESTAMP,
    event_id     TIMEUUID,
    station_id   TEXT,
    station_name TEXT,
    event_type   TEXT,
    vehicle_type TEXT,
    PRIMARY KEY ((user_id, month), event_time, event_id)
) WITH CLUSTERING ORDER BY (event_time DESC, event_id ASC);
```

### Objectif

*En tant qu'utilisateur*, consulter mes propres connexions et actions sur les 30 derniers jours (US-C3 - audit personnel), sans toucher aux données des autres utilisateurs.

### Choix de clé

La partition est :

```sql
(user_id, month)
```

Cela permet de retrouver rapidement les événements d'un utilisateur pour un mois donné, sans scanner toute la base.

## 8. Table `daily_station_stats`

```sql
CREATE TABLE daily_station_stats (
    station_id     TEXT,
    day            DATE,
    total_events   COUNTER,
    total_rents    COUNTER,
    total_returns  COUNTER,
    PRIMARY KEY (station_id, day)
) WITH CLUSTERING ORDER BY (day DESC);
```

### Objectif

*En tant qu'analyste*, obtenir l'évolution journalière du nombre de passages pour identifier les pics d'affluence (US-C4), sans déclencher un scan complet de `station_passages`.

### Pourquoi des compteurs ?

Cassandra n'est pas conçue pour faire des agrégations globales à la volée sur des millions de lignes. *En tant que système*, on prépare donc les statistiques à l'écriture : chaque événement incrémente directement les COUNTER, et l'analyste lit un résultat pré-calculé.

Les colonnes `COUNTER` permettent d'incrémenter directement :

- le nombre total d'événements ;
- le nombre de locations ;
- le nombre de retours.

## 9. Réponse à US-C2 : écritures massives

*En tant que système*, le modèle supporte l'enregistrement de plusieurs milliers d'événements de passage par minute parce que :

- les écritures sont append-only ;
- il n'y a pas de jointure ;
- les partitions sont distribuables par station et par jour ;
- les événements sont écrits dans des tables optimisées pour leurs lectures ;
- dans un cluster réel, les noeuds Cassandra se répartissent automatiquement les partitions.

## 10. Cohérence des événements

Chaque événement possède un `event_id` identique dans `station_passages` et `user_connexions`.

Exemple :

```sql
BEGIN BATCH
INSERT INTO station_passages (...) VALUES (..., 00000001-0000-1000-8000-000000000001, ...);
INSERT INTO user_connexions (...) VALUES (..., 00000001-0000-1000-8000-000000000001, ...);
APPLY BATCH;
```

Cela permet de corréler les deux vues si besoin.

> **Note sur l'usage de BEGIN BATCH dans le seed**
>
> Dans le script de seed, `BEGIN BATCH` est utilisé uniquement pour initialiser plusieurs tables
> cohérentes à partir des mêmes événements. Cela garantit que chaque événement apparait dans
> `station_passages` et `user_connexions` avec le même `event_id`, ce qui est pratique pour
> une démonstration.
>
> En production, on éviterait les batches massifs dans Cassandra, car le modèle repose sur
> des écritures rapides et distribuées. Les écritures seraient pilotées par la couche applicative
> selon les tables nécessaires aux requêtes, sans passer par des batches coordonnés qui
> augmentent la charge sur les coordinateurs de cluster.

## 11. User stories couvertes

| User story | Description | Table |
|---|---|---|
| US-C1 | Historique des passages d'une station | `station_passages` |
| US-C2 | Enregistrement massif d'événements | `station_passages`, `user_connexions` |
| US-C3 | Connexions d'un utilisateur sur 30 jours | `user_connexions` |
| US-C4 | Évolution journalière des passages | `daily_station_stats` |

## 12. Limites assumées

- Une période de plusieurs jours nécessite une requête par jour.
- Une recherche sur plusieurs stations nécessite une requête par station.
- Les données sont dupliquées volontairement.
- Les compteurs Cassandra doivent être utilisés séparément des insertions classiques.
