# CityFlow - Guide de démonstration

Ce guide permet de lancer le projet et de démontrer une requête représentative par base
en moins de 10 minutes.

---

## Etape 1 - Lancer le projet

```bash
cp .env.example .env
docker compose up -d
```

Le démarrage prend environ 60 à 90 secondes. Cassandra et Neo4j sont les plus lents à
initialiser. Les containers `*-seed` attendent que leur base soit prête avant d'injecter
les données.

---

## Etape 2 - Vérifier que tout est lancé

```bash
docker compose ps
```

Résultat attendu : tous les services doivent être à l'état `running` (ou `exited` pour les
containers de seed, ce qui est normal une fois le seed terminé).

---

## Etape 3 - Vérifier l'accès à chaque base

```bash
# MongoDB
docker exec -it cityflow-mongo mongosh -u admin -p cityflow2025 \
  --authenticationDatabase admin --eval "db.adminCommand('ping')"
# Attendu : { ok: 1 }

# Redis
docker exec -it cityflow-redis redis-cli -a cityflow2025 PING
# Attendu : PONG

# Cassandra
docker exec -it cityflow-cassandra cqlsh -e "DESCRIBE KEYSPACES;"
# Attendu : cityflow apparait dans la liste

# Neo4j - ouvrir dans le navigateur
# http://localhost:7474  (neo4j / cityflow2025)
# Puis lancer : MATCH (n) RETURN count(n)
# Attendu : 19 (15 stations + 4 lignes)
```

---

## Etape 4 - Requêtes de démonstration

### MongoDB - US-M1 : profil + 10 derniers trajets d'un utilisateur

```bash
docker exec -it cityflow-mongo mongosh -u admin -p cityflow2025 \
  --authenticationDatabase admin --quiet --eval "
db = db.getSiblingDB('cityflow');
db.trips.find({ userId: 'u001' }).sort({ date: -1 }).limit(10).pretty();
"
```

**Ce que cela démontre :** requête indexée `{ userId: 1, date: -1 }`, tri par date
décroissante, limite à 10 résultats.
**Résultat attendu :** les trajets d'Alice Martin (u001), du plus récent au plus ancien,
avec les étapes imbriquées et les commentaires.

---

### MongoDB - US-M3 : statistiques agrégées

```bash
docker exec -it cityflow-mongo mongosh -u admin -p cityflow2025 \
  --authenticationDatabase admin --quiet --eval "
db = db.getSiblingDB('cityflow');
db.trips.aggregate([
  { \$group: { _id: { \$dateToString: { format: '%Y-%m-%d', date: '\$date' } },
               total: { \$sum: 1 },
               distanceMoy: { \$avg: '\$distance' } } },
  { \$sort: { _id: -1 } },
  { \$limit: 7 }
]).pretty();
"
```

**Ce que cela démontre :** Aggregation Pipeline MongoDB (group, avg, sort).
**Résultat attendu :** nombre de trajets et distance moyenne par jour sur les 7 derniers jours.

---

### Redis - US-R1 : disponibilité d'une station en temps réel

```bash
docker exec -it cityflow-redis redis-cli -a cityflow2025 HGETALL station:S001:availability
```

**Ce que cela démontre :** lecture d'un Hash Redis en O(1), latence sub-milliseconde.
**Résultat attendu :** champs `name`, `bikes`, `scooters`, `capacity` pour la station S001.

---

### Redis - US-R3 : leaderboard mensuel

```bash
docker exec -it cityflow-redis redis-cli -a cityflow2025 \
  ZREVRANGE leaderboard:monthly:2025-06 0 9 WITHSCORES
```

**Ce que cela démontre :** Sorted Set Redis, tri automatique par score, top 10 en une commande.
**Résultat attendu :** liste des userId avec leur score (nombre de trajets), du plus actif
au moins actif.

---

### Redis - US-R2 : session avec TTL

```bash
docker exec -it cityflow-redis redis-cli -a cityflow2025 TTL session:tok001
docker exec -it cityflow-redis redis-cli -a cityflow2025 HGETALL session:tok001
```

**Ce que cela démontre :** Hash Redis avec expiration automatique (sliding TTL de 1800s).
**Résultat attendu :** TTL restant en secondes, puis les champs de session (userId, role,
lastAction).

---

### Cassandra - US-C1 : historique des passages d'une station sur une journée

```bash
docker exec -it cityflow-cassandra cqlsh -e "
USE cityflow;
SELECT station_id, event_time, user_id, event_type, vehicle_type
FROM station_passages
WHERE station_id = 'ST001' AND day = '2025-06-15'
ORDER BY event_time DESC
LIMIT 10;
"
```

**Ce que cela démontre :** requête Cassandra par Partition Key `(station_id, day)`, lecture
en O(1) sans scan, clustering order DESC.
**Résultat attendu :** les 10 passages les plus récents à la station ST001 le 15 juin 2025.

---

### Cassandra - US-C3 : connexions d'un utilisateur sur 30 jours

```bash
docker exec -it cityflow-cassandra cqlsh -e "
USE cityflow;
SELECT event_time, station_name, event_type, vehicle_type
FROM user_connexions
WHERE user_id = 'u001' AND month = '2025-06'
ORDER BY event_time DESC;
"
```

**Ce que cela démontre :** modèle dénormalisé, partition par `(user_id, month)`, chaque
utilisateur lit uniquement sa propre partition.
**Résultat attendu :** toutes les connexions de u001 en juin 2025, avec station et type
d'évènement.

---

### Cassandra - US-C4 : évolution journalière des passages (COUNTER)

```bash
docker exec -it cityflow-cassandra cqlsh -e "
USE cityflow;
SELECT station_id, day, total_events, total_rents, total_returns
FROM daily_station_stats
WHERE station_id = 'ST001';
"
```

**Ce que cela démontre :** colonnes COUNTER Cassandra, statistiques pré-calculées à
l'écriture pour éviter les agrégations coûteuses à la lecture.
**Résultat attendu :** total d'événements, de locations et de retours par jour pour ST001.

---

### Neo4j - US-N1 : plus court chemin entre deux stations

Ouvrir le Neo4j Browser à l'adresse **http://localhost:7474** (neo4j / cityflow2025),
puis copier-coller la requête suivante :

```cypher
MATCH (start:Station {code: 'S01'}), (end:Station {code: 'S08'})
MATCH path = shortestPath((start)-[:CONNECTED_TO*]-(end))
RETURN [n IN nodes(path) | n.name] AS chemin,
       length(path) AS nb_connexions;
```

**Ce que cela démontre :** algorithme `shortestPath` natif de Neo4j, traversée du graphe
de transport.
**Résultat attendu :** le chemin le plus court (en nombre de stations) entre Perrache (S01)
et Laurent Bonnevay (S08), avec le nombre de connexions.

---

### Neo4j - US-N3 : identification des stations hubs

```cypher
MATCH (s:Station)-[:CONNECTED_TO]->(voisin:Station)
RETURN s.name AS station, count(voisin) AS connexions_directes
ORDER BY connexions_directes DESC
LIMIT 5;
```

**Ce que cela démontre :** agrégation sur les relations `:CONNECTED_TO`, tri par degré
sortant pour identifier les noeuds les plus connectés du graphe.
**Résultat attendu :** le top 5 des stations les plus connectées du réseau lyonnais
(Bellecour et Foch sont attendus en tête).

---

### Neo4j - US-N2 : stations accessibles en moins de 15 minutes

```cypher
MATCH (start:Station {code: 'S02'})
MATCH path = (start)-[:CONNECTED_TO*1..6]->(end:Station)
WHERE start <> end
WITH end, reduce(total = 0, r IN relationships(path) | total + r.duration_min) AS duree
WHERE duree < 15
RETURN DISTINCT end.name AS station, min(duree) AS duree_min
ORDER BY duree_min ASC;
```

**Ce que cela démontre :** chemin variable-length, fonction `reduce()` pour sommer les
durées sur le chemin, filtre sur le temps total.
**Résultat attendu :** toutes les stations accessibles depuis Bellecour (S02) en moins de
15 minutes, triées du plus proche au plus loin.

---

## Etape 5 - User stories démontrées

| User story | Base | Requête de démo |
|------------|------|-----------------|
| US-M1 | MongoDB | Profil + 10 derniers trajets de u001 |
| US-M3 | MongoDB | Agrégation trajets/jour + distance moyenne |
| US-R1 | Redis | HGETALL disponibilité station S001 |
| US-R2 | Redis | TTL et champs de la session tok001 |
| US-R3 | Redis | ZREVRANGE leaderboard top 10 |
| US-C1 | Cassandra | Passages station ST001 le 2025-06-15 |
| US-C3 | Cassandra | Connexions u001 sur juin 2025 |
| US-C4 | Cassandra | Stats journalières COUNTER station ST001 |
| US-N1 | Neo4j | shortestPath Perrache -> Laurent Bonnevay |
| US-N2 | Neo4j | Stations < 15 min depuis Bellecour |
| US-N3 | Neo4j | Top 5 stations hubs du réseau |

> Les user stories M2, M4, R4, C2 et N4 sont documentées avec requêtes complètes dans
> les fichiers `queries/`.

---

## Origine des données

Les données du projet sont fictives et générées pour les besoins du TP.

- Les noms d'utilisateurs, trajets et véhicules sont inventés.
- Les noms de stations sont ceux du vrai réseau TCL de Lyon (Bellecour, Perrache, Part-Dieu...) mais les disponibilités, événements et horodatages sont fabriqués.
- Les lignes de métro A/B/C/D s'inspirent du réseau lyonnais réel, avec des durées approximées.

"J'ai généré des données fictives représentatives d'un vrai réseau de mobilité lyonnais, en m'inspirant de la géographie réelle de Lyon pour rendre le jeu de données cohérent et démontrable."
