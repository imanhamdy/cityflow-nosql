# Modélisation Neo4j - CityFlow

## 1. Rôle de Neo4j dans CityFlow

Neo4j stocke le **réseau de transport** de la métropole lyonnaise. C'est la base de données
idéale pour les relations complexes entre stations, les calculs de chemin et la détection de
nœuds centraux (hubs).

Les autres bases ne peuvent pas couvrir ce besoin :
- MongoDB : orienté document, pas de traversée de graphe
- Redis : mémoire vive, pas adapté aux algorithmes de chemin
- Cassandra : time-series, pas de jointures ni de graphe

## 2. Schéma du graphe

```
(:Line)-[:SERVES {order}]->(:Station)-[:CONNECTED_TO {duration_min}]->(:Station)
```

### Labels de nœuds

| Label | Description | Propriétés |
|-------|-------------|------------|
| `:Station` | Une station du réseau | `code`, `name`, `lat`, `lon` |
| `:Line` | Une ligne de métro | `number`, `name`, `color` |

Un seul label `:Station` est utilisé (pas de `:MetroStation`, `:BusStation`). Le réseau CityFlow
est un réseau de métro homogène. Le label unique simplifie toutes les requêtes de traversée.

### Types de relations

| Type | Direction | Propriétés | Usage |
|------|-----------|------------|-------|
| `:CONNECTED_TO` | `Station → Station` | `duration_min` | Liaison physique entre deux stations adjacentes |
| `:SERVES` | `Line → Station` | `order` | La ligne dessert la station à cet ordre |

#### Pourquoi `:CONNECTED_TO` bidirectionnel ?

Les relations `:CONNECTED_TO` sont créées dans les deux sens (`A→B` et `B→A`). Cela permet
d'utiliser des patterns dirigés simples dans les requêtes (`-[:CONNECTED_TO*]->`) sans
perdre la capacité de parcourir le graphe dans les deux sens.

#### Pourquoi `:SERVES` plutôt qu'un nœud `:LineSegment` ?

Un nœud `:LineSegment` aurait permis de représenter l'ordre des stations sur une ligne comme
un chemin de nœuds. Mais il aurait compliqué les requêtes sans apporter de bénéfice pour
nos 4 user stories. La propriété `order` sur `:SERVES` est suffisante.

## 3. Contraintes d'unicité

```cypher
CREATE CONSTRAINT station_code IF NOT EXISTS FOR (s:Station) REQUIRE s.code IS UNIQUE;
CREATE CONSTRAINT line_number IF NOT EXISTS FOR (l:Line) REQUIRE l.number IS UNIQUE;
```

## 4. DDL complet

```cypher
// Stations
CREATE (:Station {code: 'S01', name: 'Perrache', lat: 45.7491, lon: 4.8267});
// ... 15 stations au total

// Lignes
CREATE (:Line {number: 'A', name: 'Métro A', color: 'rouge'});
// ... 4 lignes au total

// Connexions
MATCH (a:Station {code: 'S01'}), (b:Station {code: 'S09'})
CREATE (a)-[:CONNECTED_TO {duration_min: 2}]->(b),
       (b)-[:CONNECTED_TO {duration_min: 2}]->(a);

// Dessertes
MATCH (l:Line {number: 'A'}), (s:Station {code: 'S01'})
CREATE (l)-[:SERVES {order: 1}]->(s);
```

## 5. Réseau modélisé

### Ligne A (rouge) — 9 stations

```
Perrache → Ampère → Bellecour → Cordeliers → Hôtel de Ville
→ Foch → Saxe-Gambetta → Charpennes → Laurent Bonnevay
```

### Ligne B (bleu) — 8 stations

```
Gerland → Jean Macé → Perrache → Bellecour
→ Foch → Brotteaux → Charpennes → Laurent Bonnevay
```

### Ligne C (orange) — 3 stations

```
Hôtel de Ville → Croix-Paquet → Cuire
```

### Ligne D (vert) — 7 stations

```
Vieux-Lyon → Bellecour → Cordeliers → Hôtel de Ville
→ Foch → Saxe-Gambetta → Gerland
```

## 6. Statistiques du graphe

| Élément | Nombre |
|---------|--------|
| Nœuds `:Station` | 15 |
| Nœuds `:Line` | 4 |
| Relations `:CONNECTED_TO` | 34 (17 segments × 2 directions) |
| Relations `:SERVES` | 27 |
| **Total nœuds** | **19** |
| **Total relations** | **61** |

## 7. Estimations des partitions

Avec un réseau de transport réel à l'échelle de la métropole lyonnaise :

- ~200 stations → ~200 nœuds `:Station`
- ~30 lignes → ~30 nœuds `:Line`
- ~800 segments bidirectionnels → ~1 600 relations `:CONNECTED_TO`
- ~3 000 dessertes → ~3 000 relations `:SERVES`

Neo4j est conçu pour des graphes à des milliards de nœuds et de relations. Cette taille
reste marginale.

## 8. User stories couvertes

| User story | Description | Mécanisme Cypher |
|------------|-------------|-----------------|
| US-N1 | Plus court chemin entre 2 stations | `shortestPath` / `apoc.algo.dijkstra` |
| US-N2 | Stations accessibles en < 15 min | Path variable-length + `reduce()` |
| US-N3 | Stations hubs (plus connectées) | `count()` sur `:CONNECTED_TO` + `ORDER BY` |
| US-N4 | Itinéraire sans correspondance | Match `:Line` commune entre 2 stations |

## 9. Limites assumées

- `shortestPath` minimise le nombre de sauts, pas le temps total. Pour le temps minimal,
  il faut APOC (`apoc.algo.dijkstra`) ou GDS (Graph Data Science).
- Pour US-N2, un chemin peut passer plusieurs fois par la même station si le graphe contient
  des cycles. La clause `WHERE start <> end` et `DISTINCT` limitent les doublons.
- La propriété `order` sur `:SERVES` permet de reconstituer l'ordre de passage sur une ligne
  mais ne garantit pas les horaires réels.
