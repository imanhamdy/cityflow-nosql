# Architecture CityFlow - Persistance Polyglotte

## 1. Vue d'ensemble

CityFlow adopte une architecture de **persistance polyglotte** : chaque type de donnée est
stocké dans la base de données la mieux adaptée à ses contraintes d'accès, de volume et de
structure. Quatre bases NoSQL cohabitent, orchestrées par Docker Compose.

```
┌─────────────────────────────────────────────────────────────────┐
│                      Application CityFlow                       │
│                   (couche applicative - hors périmètre)         │
└───────┬───────────────┬──────────────────┬──────────────────────┘
        │               │                  │                  │
        ▼               ▼                  ▼                  ▼
  ┌──────────┐   ┌──────────┐   ┌─────────────┐   ┌──────────────┐
  │ MongoDB  │   │  Redis   │   │  Cassandra  │   │    Neo4j     │
  │  :27017  │   │  :6379   │   │    :9042    │   │  :7687/:7474 │
  │          │   │          │   │             │   │              │
  │ Profils  │   │  Cache   │   │   Logs de   │   │   Réseau de  │
  │ Trajets  │   │Sessions  │   │  passages   │   │   transport  │
  │Véhicules │   │Leaderbd. │   │(time-series)│   │  (graphe)    │
  └──────────┘   └──────────┘   └─────────────┘   └──────────────┘
```

## 2. Répartition des responsabilités

### MongoDB - Données métier riches et flexibles

**Ce qu'on stocke :** profils utilisateurs, historique des trajets, catalogue des véhicules.

**Pourquoi MongoDB :**
- Les trajets sont des documents imbriqués (étapes GPS, commentaires, véhicule associé)
  qu'il serait coûteux de normaliser en SQL.
- Le schéma évolue facilement (ajout d'un champ `eco_score` sans migration).
- Les agrégations analytiques (top conducteurs, distance moyenne) sont natives avec le
  framework Aggregation.
- L'index full-text sur les commentaires couvre US-M4 sans infrastructure externe.

**Ce qu'on ne fait pas avec MongoDB :**
- Données à faible latence temps-réel → Redis
- Séries temporelles à haut débit d'écriture → Cassandra
- Traversées de graphe → Neo4j

### Redis - Temps réel et performances

**Ce qu'on stocke :** disponibilités de stations (STRING), sessions utilisateurs (HASH + TTL),
classement mensuel (SORTED SET), compteurs de rate limiting (STRING + TTL).

**Pourquoi Redis :**
- Latence sub-milliseconde indispensable pour afficher la disponibilité en temps réel.
- L'expiration automatique (TTL) gère les sessions et les fenêtres de rate limiting sans
  cron job.
- Les Sorted Sets permettent le classement des utilisateurs en O(log n).
- Complète MongoDB : Redis cache les données chaudes, MongoDB persiste les données froides.

**Ce qu'on ne fait pas avec Redis :**
- Persistance durée de vie longue → MongoDB ou Cassandra
- Requêtes ad-hoc sur des données structurées → MongoDB

### Cassandra - Historique massif et time-series

**Ce qu'on stocke :** événements de passage aux stations (`station_passages`), connexions
utilisateurs par mois (`user_connexions`), statistiques journalières agrégées
(`daily_station_stats` avec COUNTER).

**Pourquoi Cassandra :**
- Optimisé pour les **écritures massives** : 1000+ stations × 1 événement/min = millions
  d'insertions/jour sans dégradation.
- La **Partition Key** `(station_id, day)` garantit des lectures par station et par jour
  en O(1), sans scan.
- La scalabilité horizontale (ajout de nœuds) est transparente et sans downtime.
- Les COUNTER columns permettent d'incrémenter des compteurs sans `SELECT + UPDATE`.

**Ce qu'on ne fait pas avec Cassandra :**
- Jointures ou requêtes ad-hoc → MongoDB
- Traversées relationnelles → Neo4j

### Neo4j - Réseau et itinéraires

**Ce qu'on stocke :** nœuds `:Station` (15 stations lyonnaises), nœuds `:Line` (4 lignes),
relations `:CONNECTED_TO` (durée en minutes), relations `:SERVES` (ordre sur la ligne).

**Pourquoi Neo4j :**
- Un réseau de transport **est un graphe** : les relations entre stations sont le cœur du
  modèle, pas une contrainte à contourner.
- `shortestPath` et `apoc.algo.dijkstra` sont optimisés nativement pour les traversées.
- Les requêtes de type « stations accessibles en X minutes » (`reduce()` sur les chemins)
  sont impossibles à écrire simplement en SQL.
- Ajout de nouvelles lignes ou connexions → juste de nouveaux nœuds et relations, sans
  modification de schéma.

**Ce qu'on ne fait pas avec Neo4j :**
- Données volumétriques séquentielles → Cassandra
- Documents riches non-relationnels → MongoDB

## 3. Interactions entre bases

Dans une application réelle, les bases communiquent via la couche service :

```
Requête utilisateur « Planifier un trajet »
  1. Neo4j       → Calcul du plus court chemin (stations + temps)
  2. Redis        → Vérifier la disponibilité des stations en temps réel
  3. MongoDB     → Créer le trajet dans l'historique utilisateur
  4. Cassandra   → Logger l'événement de passage à chaque station
```

Pour ce projet, chaque base est interrogée indépendamment via ses propres scripts et requêtes.

## 4. Choix de ne pas utiliser un SGBD relationnel

Une base SQL unique (PostgreSQL) aurait pu stocker toutes ces données, mais au prix de :
- **Schémas rigides** pour les trajets (difficile d'imbriquer des étapes GPS sans JSONB).
- **Performances dégradées** pour les time-series (pas d'optimisation native des partitions
  par date).
- **Absence de primitives graphe** (le plus court chemin en SQL = procédures stockées
  complexes ou extension PostGIS/pgRouting).
- **Latence incompatible** avec les besoins temps réel (sessions, disponibilités).

Le surcoût opérationnel (4 bases à maintenir) est justifié par les gains fonctionnels et de
performance pour chaque domaine.
