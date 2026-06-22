// ==============================================================
// CityFlow - Neo4j Seed Data
// Réseau de transport Lyon - 15 stations, 4 lignes
// 34 connexions CONNECTED_TO, 27 dessertes SERVES
// ==============================================================

// Nettoyer la base
MATCH (n) DETACH DELETE n;

// Contraintes d'unicité
CREATE CONSTRAINT station_code IF NOT EXISTS FOR (s:Station) REQUIRE s.code IS UNIQUE;
CREATE CONSTRAINT line_number IF NOT EXISTS FOR (l:Line) REQUIRE l.number IS UNIQUE;

// ==============================================================
// STATIONS (15 stations du réseau lyonnais)
// ==============================================================
CREATE (:Station {code: 'S01', name: 'Perrache', lat: 45.7491, lon: 4.8267});
CREATE (:Station {code: 'S02', name: 'Bellecour', lat: 45.7577, lon: 4.8325});
CREATE (:Station {code: 'S03', name: 'Cordeliers', lat: 45.7624, lon: 4.8338});
CREATE (:Station {code: 'S04', name: 'Hôtel de Ville', lat: 45.7677, lon: 4.8330});
CREATE (:Station {code: 'S05', name: 'Foch', lat: 45.7680, lon: 4.8480});
CREATE (:Station {code: 'S06', name: 'Saxe-Gambetta', lat: 45.7558, lon: 4.8497});
CREATE (:Station {code: 'S07', name: 'Charpennes', lat: 45.7722, lon: 4.8644});
CREATE (:Station {code: 'S08', name: 'Laurent Bonnevay', lat: 45.7756, lon: 4.9039});
CREATE (:Station {code: 'S09', name: 'Ampère-Victor Hugo', lat: 45.7530, lon: 4.8295});
CREATE (:Station {code: 'S10', name: 'Brotteaux', lat: 45.7699, lon: 4.8498});
CREATE (:Station {code: 'S11', name: 'Jean Macé', lat: 45.7414, lon: 4.8325});
CREATE (:Station {code: 'S12', name: 'Gerland', lat: 45.7282, lon: 4.8300});
CREATE (:Station {code: 'S13', name: 'Croix-Paquet', lat: 45.7723, lon: 4.8252});
CREATE (:Station {code: 'S14', name: 'Cuire', lat: 45.7821, lon: 4.8237});
CREATE (:Station {code: 'S15', name: 'Vieux-Lyon', lat: 45.7626, lon: 4.8273});

// ==============================================================
// LIGNES (4 lignes de métro)
// ==============================================================
CREATE (:Line {number: 'A', name: 'Métro A', color: 'rouge'});
CREATE (:Line {number: 'B', name: 'Métro B', color: 'bleu'});
CREATE (:Line {number: 'C', name: 'Métro C', color: 'orange'});
CREATE (:Line {number: 'D', name: 'Métro D', color: 'vert'});

// ==============================================================
// CONNEXIONS :CONNECTED_TO (bidirectionnelles, avec duration_min)
// ==============================================================

// Ligne A: Perrache → Ampère → Bellecour → Cordeliers →
//          Hôtel de Ville → Foch → Saxe-Gambetta → Charpennes → Laurent Bonnevay
MATCH (a:Station {code: 'S01'}), (b:Station {code: 'S09'})
CREATE (a)-[:CONNECTED_TO {duration_min: 2}]->(b),
       (b)-[:CONNECTED_TO {duration_min: 2}]->(a);

MATCH (a:Station {code: 'S09'}), (b:Station {code: 'S02'})
CREATE (a)-[:CONNECTED_TO {duration_min: 2}]->(b),
       (b)-[:CONNECTED_TO {duration_min: 2}]->(a);

MATCH (a:Station {code: 'S02'}), (b:Station {code: 'S03'})
CREATE (a)-[:CONNECTED_TO {duration_min: 2}]->(b),
       (b)-[:CONNECTED_TO {duration_min: 2}]->(a);

MATCH (a:Station {code: 'S03'}), (b:Station {code: 'S04'})
CREATE (a)-[:CONNECTED_TO {duration_min: 2}]->(b),
       (b)-[:CONNECTED_TO {duration_min: 2}]->(a);

MATCH (a:Station {code: 'S04'}), (b:Station {code: 'S05'})
CREATE (a)-[:CONNECTED_TO {duration_min: 3}]->(b),
       (b)-[:CONNECTED_TO {duration_min: 3}]->(a);

MATCH (a:Station {code: 'S05'}), (b:Station {code: 'S06'})
CREATE (a)-[:CONNECTED_TO {duration_min: 3}]->(b),
       (b)-[:CONNECTED_TO {duration_min: 3}]->(a);

MATCH (a:Station {code: 'S06'}), (b:Station {code: 'S07'})
CREATE (a)-[:CONNECTED_TO {duration_min: 3}]->(b),
       (b)-[:CONNECTED_TO {duration_min: 3}]->(a);

MATCH (a:Station {code: 'S07'}), (b:Station {code: 'S08'})
CREATE (a)-[:CONNECTED_TO {duration_min: 4}]->(b),
       (b)-[:CONNECTED_TO {duration_min: 4}]->(a);

// Ligne B: Gerland → Jean Macé → Perrache → Bellecour →
//          Foch → Brotteaux → Charpennes → Laurent Bonnevay
MATCH (a:Station {code: 'S12'}), (b:Station {code: 'S11'})
CREATE (a)-[:CONNECTED_TO {duration_min: 4}]->(b),
       (b)-[:CONNECTED_TO {duration_min: 4}]->(a);

MATCH (a:Station {code: 'S11'}), (b:Station {code: 'S01'})
CREATE (a)-[:CONNECTED_TO {duration_min: 4}]->(b),
       (b)-[:CONNECTED_TO {duration_min: 4}]->(a);

MATCH (a:Station {code: 'S02'}), (b:Station {code: 'S05'})
CREATE (a)-[:CONNECTED_TO {duration_min: 3}]->(b),
       (b)-[:CONNECTED_TO {duration_min: 3}]->(a);

MATCH (a:Station {code: 'S05'}), (b:Station {code: 'S10'})
CREATE (a)-[:CONNECTED_TO {duration_min: 3}]->(b),
       (b)-[:CONNECTED_TO {duration_min: 3}]->(a);

MATCH (a:Station {code: 'S10'}), (b:Station {code: 'S07'})
CREATE (a)-[:CONNECTED_TO {duration_min: 3}]->(b),
       (b)-[:CONNECTED_TO {duration_min: 3}]->(a);

// Ligne C: Hôtel de Ville → Croix-Paquet → Cuire
MATCH (a:Station {code: 'S04'}), (b:Station {code: 'S13'})
CREATE (a)-[:CONNECTED_TO {duration_min: 3}]->(b),
       (b)-[:CONNECTED_TO {duration_min: 3}]->(a);

MATCH (a:Station {code: 'S13'}), (b:Station {code: 'S14'})
CREATE (a)-[:CONNECTED_TO {duration_min: 4}]->(b),
       (b)-[:CONNECTED_TO {duration_min: 4}]->(a);

// Ligne D: Vieux-Lyon → Bellecour → ... → Saxe-Gambetta → Gerland
MATCH (a:Station {code: 'S15'}), (b:Station {code: 'S02'})
CREATE (a)-[:CONNECTED_TO {duration_min: 4}]->(b),
       (b)-[:CONNECTED_TO {duration_min: 4}]->(a);

MATCH (a:Station {code: 'S06'}), (b:Station {code: 'S12'})
CREATE (a)-[:CONNECTED_TO {duration_min: 5}]->(b),
       (b)-[:CONNECTED_TO {duration_min: 5}]->(a);

// ==============================================================
// DESSERTES :SERVES (Ligne → Station, avec ordre de passage)
// ==============================================================

// Ligne A (9 stations)
MATCH (l:Line {number: 'A'}), (s:Station {code: 'S01'}) CREATE (l)-[:SERVES {order: 1}]->(s);
MATCH (l:Line {number: 'A'}), (s:Station {code: 'S09'}) CREATE (l)-[:SERVES {order: 2}]->(s);
MATCH (l:Line {number: 'A'}), (s:Station {code: 'S02'}) CREATE (l)-[:SERVES {order: 3}]->(s);
MATCH (l:Line {number: 'A'}), (s:Station {code: 'S03'}) CREATE (l)-[:SERVES {order: 4}]->(s);
MATCH (l:Line {number: 'A'}), (s:Station {code: 'S04'}) CREATE (l)-[:SERVES {order: 5}]->(s);
MATCH (l:Line {number: 'A'}), (s:Station {code: 'S05'}) CREATE (l)-[:SERVES {order: 6}]->(s);
MATCH (l:Line {number: 'A'}), (s:Station {code: 'S06'}) CREATE (l)-[:SERVES {order: 7}]->(s);
MATCH (l:Line {number: 'A'}), (s:Station {code: 'S07'}) CREATE (l)-[:SERVES {order: 8}]->(s);
MATCH (l:Line {number: 'A'}), (s:Station {code: 'S08'}) CREATE (l)-[:SERVES {order: 9}]->(s);

// Ligne B (8 stations)
MATCH (l:Line {number: 'B'}), (s:Station {code: 'S12'}) CREATE (l)-[:SERVES {order: 1}]->(s);
MATCH (l:Line {number: 'B'}), (s:Station {code: 'S11'}) CREATE (l)-[:SERVES {order: 2}]->(s);
MATCH (l:Line {number: 'B'}), (s:Station {code: 'S01'}) CREATE (l)-[:SERVES {order: 3}]->(s);
MATCH (l:Line {number: 'B'}), (s:Station {code: 'S02'}) CREATE (l)-[:SERVES {order: 4}]->(s);
MATCH (l:Line {number: 'B'}), (s:Station {code: 'S05'}) CREATE (l)-[:SERVES {order: 5}]->(s);
MATCH (l:Line {number: 'B'}), (s:Station {code: 'S10'}) CREATE (l)-[:SERVES {order: 6}]->(s);
MATCH (l:Line {number: 'B'}), (s:Station {code: 'S07'}) CREATE (l)-[:SERVES {order: 7}]->(s);
MATCH (l:Line {number: 'B'}), (s:Station {code: 'S08'}) CREATE (l)-[:SERVES {order: 8}]->(s);

// Ligne C (3 stations)
MATCH (l:Line {number: 'C'}), (s:Station {code: 'S04'}) CREATE (l)-[:SERVES {order: 1}]->(s);
MATCH (l:Line {number: 'C'}), (s:Station {code: 'S13'}) CREATE (l)-[:SERVES {order: 2}]->(s);
MATCH (l:Line {number: 'C'}), (s:Station {code: 'S14'}) CREATE (l)-[:SERVES {order: 3}]->(s);

// Ligne D (7 stations)
MATCH (l:Line {number: 'D'}), (s:Station {code: 'S15'}) CREATE (l)-[:SERVES {order: 1}]->(s);
MATCH (l:Line {number: 'D'}), (s:Station {code: 'S02'}) CREATE (l)-[:SERVES {order: 2}]->(s);
MATCH (l:Line {number: 'D'}), (s:Station {code: 'S03'}) CREATE (l)-[:SERVES {order: 3}]->(s);
MATCH (l:Line {number: 'D'}), (s:Station {code: 'S04'}) CREATE (l)-[:SERVES {order: 4}]->(s);
MATCH (l:Line {number: 'D'}), (s:Station {code: 'S05'}) CREATE (l)-[:SERVES {order: 5}]->(s);
MATCH (l:Line {number: 'D'}), (s:Station {code: 'S06'}) CREATE (l)-[:SERVES {order: 6}]->(s);
MATCH (l:Line {number: 'D'}), (s:Station {code: 'S12'}) CREATE (l)-[:SERVES {order: 7}]->(s);

// ==============================================================
// Vérifications
// ==============================================================
MATCH (n) RETURN count(n) AS total_noeuds;
MATCH ()-[r:CONNECTED_TO]->() RETURN count(r) AS total_connexions;
MATCH ()-[r:SERVES]->() RETURN count(r) AS total_dessertes;
