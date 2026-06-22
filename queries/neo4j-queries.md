# Requêtes Neo4j - CityFlow

## Connexion

```bash
# Via Neo4j Browser
# http://localhost:7474
# Bolt URL: bolt://localhost:7687
# Identifiants: neo4j / cityflow2025
```

```cypher
-- Vérifier la base
CALL db.schema.visualization();
```

---

## US-N1 : Plus court chemin entre deux stations

**Énoncé** : Trouver le chemin le plus court (en nombre d'arrêts) entre Perrache (S01) et Laurent Bonnevay (S08).

```cypher
MATCH (start:Station {code: 'S01'}), (end:Station {code: 'S08'})
MATCH path = shortestPath((start)-[:CONNECTED_TO*]-(end))
RETURN [n IN nodes(path) | n.name] AS chemin,
       length(path)                AS nb_connexions;
```

**Résultat attendu :**
```
chemin                                                                       nb_connexions
["Perrache","Bellecour","Foch","Brotteaux","Charpennes","Laurent Bonnevay"]  5
```

### Bonus - Chemin le moins long en temps (avec APOC)

> APOC doit être activé : `NEO4J_PLUGINS: '["apoc"]'` dans docker-compose.yml.

```cypher
MATCH (start:Station {code: 'S01'}), (end:Station {code: 'S08'})
CALL apoc.algo.dijkstra(start, end, 'CONNECTED_TO', 'duration_min')
  YIELD path, weight
RETURN [n IN nodes(path) | n.name] AS chemin_optimal,
       weight                       AS duree_totale_min;
```

---

## US-N2 : Stations accessibles en moins de 15 minutes

**Énoncé** : Depuis Bellecour (S02), lister toutes les stations atteignables en moins de 15 minutes.

```cypher
MATCH (start:Station {code: 'S02'})
MATCH path = (start)-[:CONNECTED_TO*1..6]->(end:Station)
WHERE start <> end
WITH end,
     reduce(total = 0, r IN relationships(path) | total + r.duration_min) AS duree
WHERE duree < 15
RETURN DISTINCT end.name AS station, min(duree) AS duree_min
ORDER BY duree_min ASC;
```

**Résultat attendu (extrait) :**
```
station              duree_min
Ampère-Victor Hugo   2
Cordeliers           2
Foch                 3
Saxe-Gambetta        6
...
```

---

## US-N3 : Stations les plus connectées (hubs)

**Énoncé** : Identifier les 5 stations avec le plus de connexions directes (nœuds les plus centraux).

```cypher
MATCH (s:Station)-[:CONNECTED_TO]->(voisin:Station)
RETURN s.name AS station, count(voisin) AS connexions_directes
ORDER BY connexions_directes DESC
LIMIT 5;
```

**Résultat attendu :**
```
station          connexions_directes
Bellecour        4
Foch             4
Charpennes       3
Perrache         3
Saxe-Gambetta    3
```

---

## US-N4 : Itinéraire sans correspondance

**Énoncé** : Vérifier s'il existe une ligne directe (sans changement) entre Perrache (S01) et Laurent Bonnevay (S08).

```cypher
MATCH (depart:Station {code: 'S01'}), (arrivee:Station {code: 'S08'})
OPTIONAL MATCH (l:Line)-[:SERVES]->(depart)
WHERE (l)-[:SERVES]->(arrivee)
RETURN
  CASE WHEN l IS NULL
    THEN 'Aucun trajet direct disponible'
    ELSE 'Trajet direct : Ligne ' + l.number + ' (' + l.name + ')'
  END AS resultat;
```

**Résultat attendu :**
```
resultat
Trajet direct : Ligne A (Métro A)
Trajet direct : Ligne B (Métro B)
```

### Exemple sans ligne directe : Cuire (S14) → Gerland (S12)

```cypher
MATCH (depart:Station {code: 'S14'}), (arrivee:Station {code: 'S12'})
OPTIONAL MATCH (l:Line)-[:SERVES]->(depart)
WHERE (l)-[:SERVES]->(arrivee)
RETURN
  CASE WHEN l IS NULL
    THEN 'Aucun trajet direct disponible'
    ELSE 'Trajet direct : Ligne ' + l.number + ' (' + l.name + ')'
  END AS resultat;
```

**Résultat attendu :**
```
resultat
Aucun trajet direct disponible
```

---

## Requêtes utilitaires

```cypher
-- Toutes les stations d'une ligne, dans l'ordre
MATCH (l:Line {number: 'A'})-[r:SERVES]->(s:Station)
RETURN s.name AS station, r.order AS ordre
ORDER BY r.order ASC;

-- Toutes les lignes desservant une station
MATCH (l:Line)-[:SERVES]->(s:Station {code: 'S02'})
RETURN l.number AS ligne, l.name AS nom;

-- Durée totale de la Ligne A de bout en bout
MATCH path = (:Station {code: 'S01'})-[:CONNECTED_TO*]-(:Station {code: 'S08'})
WITH path, reduce(t = 0, r IN relationships(path) | t + r.duration_min) AS duree
RETURN duree ORDER BY duree ASC LIMIT 1;
```
