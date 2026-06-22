# CityFlow - Plateforme de mobilité urbaine polyglotte

Projet fil rouge du module **NoSQL B3** - Ynov Campus Lyon 2025/2026.

CityFlow est une plateforme fictive de mobilité urbaine multimodale pour la métropole de
Lyon (covoiturage, transports en commun, vélos en libre-service). Ce dépôt démontre une
architecture de persistance polyglotte avec MongoDB, Redis, Cassandra et Neo4j, chaque
base choisie pour le besoin qu'elle couvre le mieux.

**Auteur :** Iman Hamdy - Ynov Campus Lyon, B3 INFO 2025/2026

---

## Architecture

| Base | Données | Pourquoi |
|------|---------|----------|
| **MongoDB** | Profils, trajets, véhicules | Schéma flexible, documents imbriqués, agrégation |
| **Redis** | Disponibilités, sessions, leaderboard | Latence < 1 ms, TTL natif, Sorted Set |
| **Cassandra** | Historique des passages, logs | Écritures massives, time-series, partitions |
| **Neo4j** | Stations, lignes, connexions | Graphe natif, shortestPath, Dijkstra |

Justification detaillee : [docs/architecture.md](docs/architecture.md)

---

## Lancement

```bash
cp .env.example .env
docker compose up -d
```

Toutes les bases sont peuplées automatiquement au premier démarrage.

### Interfaces

| Interface | URL | Identifiants |
|-----------|-----|--------------|
| Mongo Express | http://localhost:8081 | student / nosql2025 |
| Redis Commander | http://localhost:8082 | student / nosql2025 |
| Cassandra Web | http://localhost:8083 | - |
| Neo4j Browser | http://localhost:7474 | neo4j / cityflow2025 |

### Connexion directe

```bash
# MongoDB
docker exec -it cityflow-mongo mongosh -u admin -p cityflow2025 --authenticationDatabase admin

# Redis
docker exec -it cityflow-redis redis-cli -a cityflow2025

# Cassandra
docker exec -it cityflow-cassandra cqlsh -u cassandra -p cassandra

# Neo4j - via http://localhost:7474
```

---

## Documentation

- [Guide de démo](DEMO.md) - lancement pas à pas, une requête par base
- [Architecture globale](docs/architecture.md) - schéma Mermaid, justifications polyglotte
- [Modélisation MongoDB](docs/modelisation-mongodb.md)
- [Modélisation Redis](docs/modelisation-redis.md)
- [Modélisation Cassandra](docs/modelisation-cassandra.md)
- [Modélisation Neo4j](docs/modelisation-neo4j.md)

---

## Données de seed

| Base | Volume |
|------|--------|
| MongoDB | 20 utilisateurs, 20 véhicules, 30 trajets avec commentaires |
| Redis | 10 stations, 5 sessions, 1 leaderboard, compteurs rate limiting |
| Cassandra | 200 événements sur 7 jours, 3 tables (passages, connexions, COUNTER) |
| Neo4j | 15 stations lyonnaises, 4 lignes (A/B/C/D), 34 connexions, 27 dessertes |

---

## User stories

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

---

## Structure du dépôt

```
cityflow-nosql/
├── docker-compose.yml
├── .env.example
├── docs/
│   ├── architecture.md
│   ├── modelisation-mongodb.md
│   ├── modelisation-redis.md
│   ├── modelisation-cassandra.md
│   └── modelisation-neo4j.md
├── seed/
│   ├── mongodb/init.js
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

## FAQ

**Pourquoi MongoDB et pas Cassandra pour les trajets ?**
Les trajets sont des documents riches avec des données imbriquées et des schémas flexibles.
MongoDB gère cela naturellement et supporte l'agrégation et la recherche full-text.

**Pourquoi Redis et pas MongoDB pour les sessions ?**
Redis fournit un stockage en mémoire avec expiration TTL native et des temps d'accès
sub-milliseconde.

**Pourquoi Cassandra et pas MongoDB pour l'historique des stations ?**
Cassandra est optimisée pour les écritures massives en time-series et la scalabilité
horizontale.

**Pourquoi Neo4j et pas MongoDB pour les calculs d'itinéraires ?**
Les réseaux de transport sont des graphes. Neo4j fournit des algorithmes de plus court
chemin et de traversée nativement.

**Quel est l'inconvénient de la persistance polyglotte ?**
Plus de complexité opérationnelle, plus de technologies à maintenir, et une gestion de
la cohérence des données plus difficile.
