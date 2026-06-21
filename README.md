# CityFlow — Plateforme de mobilité urbaine polyglotte

Projet fil rouge du module **NoSQL B3** — Ynov Campus Lyon 2025/2026.

CityFlow est une plateforme fictive de mobilité urbaine multimodale pour la métropole de Lyon (covoiturage, transports en commun, vélos en libre-service). Ce dépôt contient l'architecture de persistance polyglotte : MongoDB, Redis, Cassandra et Neo4j, orchestrés via Docker Compose.

---

## Auteur

**Iman Hamdy** — Ynov Campus Lyon, B3 INFO 2025/2026

---

## Lancement en une commande

```bash
cp .env.example .env
docker compose up -d
```

Toutes les bases sont peuplées automatiquement au premier démarrage.

### Interfaces disponibles

| Interface | URL | Identifiants |
|-----------|-----|--------------|
| Mongo Express (MongoDB) | http://localhost:8081 | student / nosql2025 |
| Redis Commander | http://localhost:8082 | student / nosql2025 |
| Neo4j Browser | http://localhost:7474 | neo4j / cityflow2025 |

### Connexion directe aux bases

```bash
# MongoDB
docker exec -it cityflow-mongo mongosh -u admin -p cityflow2025 --authenticationDatabase admin
use cityflow

# Redis
docker exec -it cityflow-redis redis-cli -a cityflow2025

# Cassandra
docker exec -it cityflow-cassandra cqlsh -u cassandra -p cassandra

# Neo4j
# Via le navigateur : http://localhost:7474
```

---

## Architecture — répartition des données

| Base | Données stockées | Justification |
|------|-----------------|---------------|
| **MongoDB** | Profils utilisateurs, trajets effectués, véhicules disponibles | Schémas flexibles, documents imbriqués (étapes d'un trajet), requêtes ad-hoc fréquentes |
| **Redis** | Disponibilités des stations, sessions, leaderboard | Latence sub-milliseconde, expiration automatique, sorted sets |
| **Cassandra** | Historique des passages aux stations, logs de connexions | Volume massif d'écritures, time-series, scalabilité horizontale |
| **Neo4j** | Réseau de transport (stations, lignes, connexions) | Modèle graphe naturel, calcul de plus court chemin |

---

## Structure du dépôt

```
cityflow-nosql/
├── docker-compose.yml          # Orchestration des 4 bases
├── .env.example                # Variables d'environnement type
├── docs/
│   ├── architecture.md         # Schéma global et justifications
│   ├── modelisation-mongodb.md
│   ├── modelisation-redis.md
│   ├── modelisation-cassandra.md
│   └── modelisation-neo4j.md
├── seed/
│   ├── mongodb/init.js         # 20 users, 20 vehicles, 30 trips
│   ├── redis/init.sh
│   ├── cassandra/init.cql
│   └── neo4j/init.cypher
└── queries/
    ├── mongodb-queries.md      # US-M1 à US-M4
    ├── redis-queries.md        # US-R1 à US-R4
    ├── cassandra-queries.md    # US-C1 à US-C4
    └── neo4j-queries.md        # US-N1 à US-N4
```

---

## Documentation de modélisation

- [Modélisation MongoDB](docs/modelisation-mongodb.md) — collections users / trips / vehicles, embed vs. référence, index
- [Modélisation Redis](docs/modelisation-redis.md) — clés, structures, naming convention
- [Modélisation Cassandra](docs/modelisation-cassandra.md) — tables, partition keys, clustering columns
- [Modélisation Neo4j](docs/modelisation-neo4j.md) — nœuds, relations, propriétés
- [Architecture globale](docs/architecture.md) — vue d'ensemble et justification des choix polyglotte

---

## User stories couvertes

| ID | Description | Base |
|----|-------------|------|
| US-M1 | Profil utilisateur + 10 derniers trajets | MongoDB |
| US-M2 | Véhicules d'un type par arrondissement | MongoDB |
| US-M3 | Stats agrégées : trajets/jour, distance moyenne, top 5 conducteurs | MongoDB |
| US-M4 | Recherche full-text sur les commentaires | MongoDB |
| US-R1 | Disponibilité vélos en temps réel | Redis |
| US-R2 | Session utilisateur avec expiration 30 min | Redis |
| US-R3 | Leaderboard des 10 utilisateurs les plus actifs | Redis |
| US-R4 | Rate limiting à 100 requêtes/minute | Redis |
| US-C1 | Historique des passages d'une station sur une période | Cassandra |
| US-C2 | Enregistrement massif d'événements de passage | Cassandra |
| US-C3 | Connexions d'un utilisateur sur 30 jours | Cassandra |
| US-C4 | Évolution journalière des passages | Cassandra |
| US-N1 | Plus court chemin entre deux stations | Neo4j |
| US-N2 | Stations accessibles à moins de 15 minutes | Neo4j |
| US-N3 | Identification des stations hubs | Neo4j |
| US-N4 | Itinéraire sans correspondance | Neo4j |
