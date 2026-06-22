#!/bin/sh
# CityFlow — Redis seed data
# Lancé automatiquement par le service redis-seed dans docker-compose.
# Manuellement : docker exec -i cityflow-redis sh < seed/redis/init.sh

REDIS_HOST="${REDIS_HOST:-localhost}"
REDIS_PORT="${REDIS_PORT:-6379}"
REDIS_PASSWORD="${REDIS_PASSWORD:-cityflow2025}"

R="redis-cli --no-auth-warning -h $REDIS_HOST -p $REDIS_PORT -a $REDIS_PASSWORD"

echo ">>> CityFlow Redis seed demarre..."

# ─── 1. DISPONIBILITES DES STATIONS (16 stations) ────────────────────────────
# Structure : Hash  |  TTL : 300s pour la demo (60s en production, refresh par capteur IoT)

$R HSET station:S001:availability name "Bellecour"      district "1er arrondissement"  bikes 8  scooters 3 capacity 20
$R EXPIRE station:S001:availability 300

$R HSET station:S002:availability name "Vieux-Lyon"     district "1er arrondissement"  bikes 5  scooters 2 capacity 15
$R EXPIRE station:S002:availability 300

$R HSET station:S003:availability name "Confluence"     district "2eme arrondissement" bikes 12 scooters 6 capacity 25
$R EXPIRE station:S003:availability 300

$R HSET station:S004:availability name "Perrache"       district "2eme arrondissement" bikes 3  scooters 4 capacity 20
$R EXPIRE station:S004:availability 300

$R HSET station:S005:availability name "Part-Dieu"      district "3eme arrondissement" bikes 15 scooters 8 capacity 30
$R EXPIRE station:S005:availability 300

$R HSET station:S006:availability name "Garibaldi"      district "3eme arrondissement" bikes 6  scooters 1 capacity 15
$R EXPIRE station:S006:availability 300

$R HSET station:S007:availability name "Saxe-Gambetta"  district "3eme arrondissement" bikes 9  scooters 5 capacity 20
$R EXPIRE station:S007:availability 300

$R HSET station:S008:availability name "Croix-Rousse"   district "4eme arrondissement" bikes 2  scooters 0 capacity 10
$R EXPIRE station:S008:availability 300

$R HSET station:S009:availability name "Saint-Paul"     district "5eme arrondissement" bikes 4  scooters 3 capacity 12
$R EXPIRE station:S009:availability 300

$R HSET station:S010:availability name "Brotteaux"      district "6eme arrondissement" bikes 11 scooters 4 capacity 20
$R EXPIRE station:S010:availability 300

$R HSET station:S011:availability name "Foch"           district "6eme arrondissement" bikes 7  scooters 2 capacity 15
$R EXPIRE station:S011:availability 300

$R HSET station:S012:availability name "Jean Mace"      district "7eme arrondissement" bikes 10 scooters 6 capacity 25
$R EXPIRE station:S012:availability 300

$R HSET station:S013:availability name "Gerland"        district "7eme arrondissement" bikes 14 scooters 7 capacity 30
$R EXPIRE station:S013:availability 300

$R HSET station:S014:availability name "Mermoz"         district "8eme arrondissement" bikes 3  scooters 2 capacity 12
$R EXPIRE station:S014:availability 300

$R HSET station:S015:availability name "Vaise"          district "9eme arrondissement" bikes 8  scooters 4 capacity 18
$R EXPIRE station:S015:availability 300

$R HSET station:S016:availability name "Gorge de Loup"  district "9eme arrondissement" bikes 5  scooters 3 capacity 15
$R EXPIRE station:S016:availability 300

echo "  OK 16 stations chargees (TTL 300s)"

# ─── 2. SESSIONS UTILISATEURS (5 sessions actives) ───────────────────────────
# Structure : Hash  |  TTL : 1800s (30 min, sliding — renouvelé à chaque action HTTP)

$R HSET session:tok_u001_a1b2c3d4 userId u001 firstName Alice lastName Martin email alice.martin@cityflow.fr role passenger createdAt 2025-06-21T08:30:00Z lastAction 2025-06-21T09:00:00Z
$R EXPIRE session:tok_u001_a1b2c3d4 1800

$R HSET session:tok_u003_e5f6g7h8 userId u003 firstName Sophie lastName Leclerc email sophie.leclerc@cityflow.fr role driver createdAt 2025-06-21T07:45:00Z lastAction 2025-06-21T08:55:00Z
$R EXPIRE session:tok_u003_e5f6g7h8 1800

$R HSET session:tok_u008_i9j0k1l2 userId u008 firstName Nicolas lastName Petit email nicolas.petit@cityflow.fr role driver createdAt 2025-06-21T09:10:00Z lastAction 2025-06-21T09:12:00Z
$R EXPIRE session:tok_u008_i9j0k1l2 1800

$R HSET session:tok_u012_m3n4o5p6 userId u012 firstName Hugo lastName Fontaine email hugo.fontaine@cityflow.fr role passenger createdAt 2025-06-21T08:00:00Z lastAction 2025-06-21T08:45:00Z
$R EXPIRE session:tok_u012_m3n4o5p6 1800

$R HSET session:tok_u016_q7r8s9t0 userId u016 firstName Romain lastName Lefebvre email romain.lefebvre@cityflow.fr role driver createdAt 2025-06-21T06:30:00Z lastAction 2025-06-21T09:05:00Z
$R EXPIRE session:tok_u016_q7r8s9t0 1800

echo "  OK 5 sessions actives chargees (TTL 1800s)"

# ─── 3. LEADERBOARD MENSUEL (20 utilisateurs) ────────────────────────────────
# Structure : Sorted Set  |  TTL : aucun (clé mensuelle, rotation gérée côté applicatif)
# Score = nombre de trajets effectués ou partagés dans le mois de juin 2025

$R ZADD leaderboard:monthly:2025-06 28 u001 25 u003 22 u008 20 u016 18 u011 15 u004 14 u012 12 u007 11 u014 10 u002 9 u017 8 u019 7 u005 6 u009 5 u010 4 u015 3 u006 3 u013 2 u018 2 u020

echo "  OK Leaderboard 2025-06 charge (20 utilisateurs)"

# ─── 4. COMPTEURS DE RATE LIMITING (3 utilisateurs) ─────────────────────────
# Structure : String (compteur entier)  |  TTL : 60s (fenetre glissante par minute)
# u009 est proche du seuil (93/100), u002 est modere, u013 est bas

$R SET ratelimit:user:u002 47 EX 60
$R SET ratelimit:user:u009 93 EX 45
$R SET ratelimit:user:u013 12 EX 30

echo "  OK 3 compteurs rate limiting charges (TTL 60s)"

# ─── BONUS : NOTIFICATIONS RECENTES ──────────────────────────────────────────
# Structure : List  |  TTL : 86400s (24h)

$R RPUSH notifications:u001 "{\"type\":\"trip_completed\",\"tripId\":\"t028\",\"message\":\"Trajet Garibaldi->Bellecour termine\",\"at\":\"2025-06-05T09:00:00Z\"}"
$R RPUSH notifications:u001 "{\"type\":\"trip_completed\",\"tripId\":\"t023\",\"message\":\"Trajet Perrache->Mermoz termine\",\"at\":\"2025-05-12T10:30:00Z\"}"
$R RPUSH notifications:u001 "{\"type\":\"badge\",\"message\":\"Badge Cycliste regulier obtenu\",\"at\":\"2025-05-01T00:00:00Z\"}"
$R EXPIRE notifications:u001 86400

$R RPUSH notifications:u003 "{\"type\":\"trip_completed\",\"tripId\":\"t029\",\"message\":\"Trajet conducteur Perrache->Venissieux\",\"at\":\"2025-06-08T08:15:00Z\"}"
$R RPUSH notifications:u003 "{\"type\":\"rating\",\"message\":\"Nouvelle note 5 etoiles recue\",\"at\":\"2025-06-08T08:50:00Z\"}"
$R EXPIRE notifications:u003 86400

$R RPUSH notifications:u008 "{\"type\":\"trip_completed\",\"tripId\":\"t027\",\"message\":\"Trajet conducteur Part-Dieu->Brotteaux\",\"at\":\"2025-06-02T07:45:00Z\"}"
$R RPUSH notifications:u008 "{\"type\":\"rating\",\"message\":\"Nouvelle note 4.7 etoiles recue\",\"at\":\"2025-06-02T08:10:00Z\"}"
$R EXPIRE notifications:u008 86400

echo "  OK Notifications chargees pour u001, u003, u008 (TTL 86400s)"

# ─── BONUS : TAGS UTILISATEURS ───────────────────────────────────────────────
# Structure : Set  |  TTL : aucun (tags permanents)

$R SADD user:u001:tags premium eco-friendly frequent
$R SADD user:u003:tags premium top-driver verified
$R SADD user:u004:tags driver premium
$R SADD user:u008:tags top-driver verified frequent
$R SADD user:u011:tags top-driver premium
$R SADD user:u016:tags top-driver verified
$R SADD user:u012:tags eco-friendly frequent

echo "  OK Tags charges pour 7 utilisateurs"
echo ""
echo ">>> CityFlow Redis seed termine !"
echo "    Stations:16 | Sessions:5 | Leaderboard:20 | Rate limits:3 | Notifs:3 | Tags:7"
