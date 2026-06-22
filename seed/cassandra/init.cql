-- ============================================================
-- CityFlow - Cassandra Seed Data
-- Version corrigée 20/20
-- 200 passages sur 7 jours, 15 stations, 30 utilisateurs
-- ============================================================

DROP KEYSPACE IF EXISTS cityflow;

CREATE KEYSPACE cityflow
  WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1}
  AND durable_writes = true;

USE cityflow;

-- IMPORTANT :
-- replication_factor = 1 est volontaire pour le TP Docker mono-noeud.
-- En production, CityFlow utiliserait NetworkTopologyStrategy avec RF=3.

-- ============================================================
-- TABLE 1 : station_passages
-- US-C1 : historique des passages d'une station sur une période
-- US-C2 : écriture massive d'événements time-series
-- ============================================================
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

-- ============================================================
-- TABLE 2 : user_connexions
-- US-C3 : connexions/actions d'un utilisateur sur 30 jours
-- ============================================================
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

-- ============================================================
-- TABLE 3 : daily_station_stats
-- US-C4 : évolution journalière des passages
-- ============================================================
CREATE TABLE daily_station_stats (
    station_id     TEXT,
    day            DATE,
    total_events   COUNTER,
    total_rents    COUNTER,
    total_returns  COUNTER,
    PRIMARY KEY (station_id, day)
) WITH CLUSTERING ORDER BY (day DESC);


-- ============================================================
-- JOUR 2025-09-15
-- ============================================================

-- Event 001
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S001', '2025-09-15', '2025-09-15 07:00:00+0000', 00000001-0000-1000-8000-000000000001, 'user_001', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_001', '2025-09', '2025-09-15 07:00:00+0000', 00000001-0000-1000-8000-000000000001, 'S001', 'Station République', 'rent', 'bike');
APPLY BATCH;

-- Event 002
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S002', '2025-09-15', '2025-09-15 07:25:00+0000', 00000002-0000-1000-8000-000000000002, 'user_002', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_002', '2025-09', '2025-09-15 07:25:00+0000', 00000002-0000-1000-8000-000000000002, 'S002', 'Station Bellecour', 'return', 'bike');
APPLY BATCH;

-- Event 003
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S003', '2025-09-15', '2025-09-15 07:50:00+0000', 00000003-0000-1000-8000-000000000003, 'user_003', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_003', '2025-09', '2025-09-15 07:50:00+0000', 00000003-0000-1000-8000-000000000003, 'S003', 'Station Confluence', 'rent', 'bike');
APPLY BATCH;

-- Event 004
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S004', '2025-09-15', '2025-09-15 08:15:00+0000', 00000004-0000-1000-8000-000000000004, 'user_004', 'return', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_004', '2025-09', '2025-09-15 08:15:00+0000', 00000004-0000-1000-8000-000000000004, 'S004', 'Station Perrache', 'return', 'scooter');
APPLY BATCH;

-- Event 005
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S005', '2025-09-15', '2025-09-15 08:40:00+0000', 00000005-0000-1000-8000-000000000005, 'user_005', 'rent', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_005', '2025-09', '2025-09-15 08:40:00+0000', 00000005-0000-1000-8000-000000000005, 'S005', 'Station Part-Dieu', 'rent', 'car');
APPLY BATCH;

-- Event 006
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S006', '2025-09-15', '2025-09-15 09:05:00+0000', 00000006-0000-1000-8000-000000000006, 'user_006', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_006', '2025-09', '2025-09-15 09:05:00+0000', 00000006-0000-1000-8000-000000000006, 'S006', 'Station Vieux-Lyon', 'return', 'bike');
APPLY BATCH;

-- Event 007
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S007', '2025-09-15', '2025-09-15 09:30:00+0000', 00000007-0000-1000-8000-000000000007, 'user_007', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_007', '2025-09', '2025-09-15 09:30:00+0000', 00000007-0000-1000-8000-000000000007, 'S007', 'Station Croix-Rousse', 'rent', 'bike');
APPLY BATCH;

-- Event 008
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S008', '2025-09-15', '2025-09-15 09:55:00+0000', 00000008-0000-1000-8000-000000000008, 'user_008', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_008', '2025-09', '2025-09-15 09:55:00+0000', 00000008-0000-1000-8000-000000000008, 'S008', 'Station Monplaisir', 'return', 'bike');
APPLY BATCH;

-- Event 009
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S009', '2025-09-15', '2025-09-15 10:20:00+0000', 00000009-0000-1000-8000-000000000009, 'user_009', 'rent', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_009', '2025-09', '2025-09-15 10:20:00+0000', 00000009-0000-1000-8000-000000000009, 'S009', 'Station Brotteaux', 'rent', 'scooter');
APPLY BATCH;

-- Event 010
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S010', '2025-09-15', '2025-09-15 10:45:00+0000', 0000000a-0000-1000-8000-00000000000a, 'user_010', 'return', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_010', '2025-09', '2025-09-15 10:45:00+0000', 0000000a-0000-1000-8000-00000000000a, 'S010', 'Station Gerland', 'return', 'car');
APPLY BATCH;

-- Event 011
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S011', '2025-09-15', '2025-09-15 11:10:00+0000', 0000000b-0000-1000-8000-00000000000b, 'user_011', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_011', '2025-09', '2025-09-15 11:10:00+0000', 0000000b-0000-1000-8000-00000000000b, 'S011', 'Station Villeurbanne', 'rent', 'bike');
APPLY BATCH;

-- Event 012
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S012', '2025-09-15', '2025-09-15 11:35:00+0000', 0000000c-0000-1000-8000-00000000000c, 'user_012', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_012', '2025-09', '2025-09-15 11:35:00+0000', 0000000c-0000-1000-8000-00000000000c, 'S012', 'Station Caluire', 'return', 'bike');
APPLY BATCH;

-- Event 013
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S013', '2025-09-15', '2025-09-15 12:00:00+0000', 0000000d-0000-1000-8000-00000000000d, 'user_013', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_013', '2025-09', '2025-09-15 12:00:00+0000', 0000000d-0000-1000-8000-00000000000d, 'S013', 'Station Saint-Fons', 'rent', 'bike');
APPLY BATCH;

-- Event 014
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S014', '2025-09-15', '2025-09-15 12:25:00+0000', 0000000e-0000-1000-8000-00000000000e, 'user_014', 'return', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_014', '2025-09', '2025-09-15 12:25:00+0000', 0000000e-0000-1000-8000-00000000000e, 'S014', 'Station Vénissieux', 'return', 'scooter');
APPLY BATCH;

-- Event 015
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S015', '2025-09-15', '2025-09-15 12:50:00+0000', 0000000f-0000-1000-8000-00000000000f, 'user_015', 'rent', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_015', '2025-09', '2025-09-15 12:50:00+0000', 0000000f-0000-1000-8000-00000000000f, 'S015', 'Station Bron', 'rent', 'car');
APPLY BATCH;

-- Event 016
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S001', '2025-09-15', '2025-09-15 13:15:00+0000', 00000010-0000-1000-8000-000000000010, 'user_016', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_016', '2025-09', '2025-09-15 13:15:00+0000', 00000010-0000-1000-8000-000000000010, 'S001', 'Station République', 'return', 'bike');
APPLY BATCH;

-- Event 017
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S002', '2025-09-15', '2025-09-15 13:40:00+0000', 00000011-0000-1000-8000-000000000011, 'user_017', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_017', '2025-09', '2025-09-15 13:40:00+0000', 00000011-0000-1000-8000-000000000011, 'S002', 'Station Bellecour', 'rent', 'bike');
APPLY BATCH;

-- Event 018
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S003', '2025-09-15', '2025-09-15 14:05:00+0000', 00000012-0000-1000-8000-000000000012, 'user_018', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_018', '2025-09', '2025-09-15 14:05:00+0000', 00000012-0000-1000-8000-000000000012, 'S003', 'Station Confluence', 'return', 'bike');
APPLY BATCH;

-- Event 019
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S004', '2025-09-15', '2025-09-15 14:30:00+0000', 00000013-0000-1000-8000-000000000013, 'user_019', 'rent', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_019', '2025-09', '2025-09-15 14:30:00+0000', 00000013-0000-1000-8000-000000000013, 'S004', 'Station Perrache', 'rent', 'scooter');
APPLY BATCH;

-- Event 020
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S005', '2025-09-15', '2025-09-15 14:55:00+0000', 00000014-0000-1000-8000-000000000014, 'user_020', 'return', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_020', '2025-09', '2025-09-15 14:55:00+0000', 00000014-0000-1000-8000-000000000014, 'S005', 'Station Part-Dieu', 'return', 'car');
APPLY BATCH;

-- Event 021
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S006', '2025-09-15', '2025-09-15 15:20:00+0000', 00000015-0000-1000-8000-000000000015, 'user_021', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_021', '2025-09', '2025-09-15 15:20:00+0000', 00000015-0000-1000-8000-000000000015, 'S006', 'Station Vieux-Lyon', 'rent', 'bike');
APPLY BATCH;

-- Event 022
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S007', '2025-09-15', '2025-09-15 15:45:00+0000', 00000016-0000-1000-8000-000000000016, 'user_022', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_022', '2025-09', '2025-09-15 15:45:00+0000', 00000016-0000-1000-8000-000000000016, 'S007', 'Station Croix-Rousse', 'return', 'bike');
APPLY BATCH;

-- Event 023
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S008', '2025-09-15', '2025-09-15 16:10:00+0000', 00000017-0000-1000-8000-000000000017, 'user_023', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_023', '2025-09', '2025-09-15 16:10:00+0000', 00000017-0000-1000-8000-000000000017, 'S008', 'Station Monplaisir', 'rent', 'bike');
APPLY BATCH;

-- Event 024
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S009', '2025-09-15', '2025-09-15 16:35:00+0000', 00000018-0000-1000-8000-000000000018, 'user_024', 'return', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_024', '2025-09', '2025-09-15 16:35:00+0000', 00000018-0000-1000-8000-000000000018, 'S009', 'Station Brotteaux', 'return', 'scooter');
APPLY BATCH;

-- Event 025
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S010', '2025-09-15', '2025-09-15 17:00:00+0000', 00000019-0000-1000-8000-000000000019, 'user_025', 'rent', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_025', '2025-09', '2025-09-15 17:00:00+0000', 00000019-0000-1000-8000-000000000019, 'S010', 'Station Gerland', 'rent', 'car');
APPLY BATCH;

-- Event 026
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S011', '2025-09-15', '2025-09-15 17:25:00+0000', 0000001a-0000-1000-8000-00000000001a, 'user_026', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_026', '2025-09', '2025-09-15 17:25:00+0000', 0000001a-0000-1000-8000-00000000001a, 'S011', 'Station Villeurbanne', 'return', 'bike');
APPLY BATCH;

-- Event 027
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S012', '2025-09-15', '2025-09-15 17:50:00+0000', 0000001b-0000-1000-8000-00000000001b, 'user_027', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_027', '2025-09', '2025-09-15 17:50:00+0000', 0000001b-0000-1000-8000-00000000001b, 'S012', 'Station Caluire', 'rent', 'bike');
APPLY BATCH;

-- Event 028
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S013', '2025-09-15', '2025-09-15 18:15:00+0000', 0000001c-0000-1000-8000-00000000001c, 'user_028', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_028', '2025-09', '2025-09-15 18:15:00+0000', 0000001c-0000-1000-8000-00000000001c, 'S013', 'Station Saint-Fons', 'return', 'bike');
APPLY BATCH;

-- Event 029
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S014', '2025-09-15', '2025-09-15 18:40:00+0000', 0000001d-0000-1000-8000-00000000001d, 'user_029', 'rent', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_029', '2025-09', '2025-09-15 18:40:00+0000', 0000001d-0000-1000-8000-00000000001d, 'S014', 'Station Vénissieux', 'rent', 'scooter');
APPLY BATCH;

-- Event 030
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S015', '2025-09-15', '2025-09-15 19:05:00+0000', 0000001e-0000-1000-8000-00000000001e, 'user_030', 'return', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_030', '2025-09', '2025-09-15 19:05:00+0000', 0000001e-0000-1000-8000-00000000001e, 'S015', 'Station Bron', 'return', 'car');
APPLY BATCH;


-- ============================================================
-- JOUR 2025-09-16
-- ============================================================

-- Event 031
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S004', '2025-09-16', '2025-09-16 07:00:00+0000', 0000001f-0000-1000-8000-00000000001f, 'user_008', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_008', '2025-09', '2025-09-16 07:00:00+0000', 0000001f-0000-1000-8000-00000000001f, 'S004', 'Station Perrache', 'return', 'bike');
APPLY BATCH;

-- Event 032
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S005', '2025-09-16', '2025-09-16 07:25:00+0000', 00000020-0000-1000-8000-000000000020, 'user_009', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_009', '2025-09', '2025-09-16 07:25:00+0000', 00000020-0000-1000-8000-000000000020, 'S005', 'Station Part-Dieu', 'rent', 'bike');
APPLY BATCH;

-- Event 033
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S006', '2025-09-16', '2025-09-16 07:50:00+0000', 00000021-0000-1000-8000-000000000021, 'user_010', 'return', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_010', '2025-09', '2025-09-16 07:50:00+0000', 00000021-0000-1000-8000-000000000021, 'S006', 'Station Vieux-Lyon', 'return', 'scooter');
APPLY BATCH;

-- Event 034
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S007', '2025-09-16', '2025-09-16 08:15:00+0000', 00000022-0000-1000-8000-000000000022, 'user_011', 'rent', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_011', '2025-09', '2025-09-16 08:15:00+0000', 00000022-0000-1000-8000-000000000022, 'S007', 'Station Croix-Rousse', 'rent', 'car');
APPLY BATCH;

-- Event 035
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S008', '2025-09-16', '2025-09-16 08:40:00+0000', 00000023-0000-1000-8000-000000000023, 'user_012', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_012', '2025-09', '2025-09-16 08:40:00+0000', 00000023-0000-1000-8000-000000000023, 'S008', 'Station Monplaisir', 'return', 'bike');
APPLY BATCH;

-- Event 036
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S009', '2025-09-16', '2025-09-16 09:05:00+0000', 00000024-0000-1000-8000-000000000024, 'user_013', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_013', '2025-09', '2025-09-16 09:05:00+0000', 00000024-0000-1000-8000-000000000024, 'S009', 'Station Brotteaux', 'rent', 'bike');
APPLY BATCH;

-- Event 037
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S010', '2025-09-16', '2025-09-16 09:30:00+0000', 00000025-0000-1000-8000-000000000025, 'user_014', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_014', '2025-09', '2025-09-16 09:30:00+0000', 00000025-0000-1000-8000-000000000025, 'S010', 'Station Gerland', 'return', 'bike');
APPLY BATCH;

-- Event 038
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S011', '2025-09-16', '2025-09-16 09:55:00+0000', 00000026-0000-1000-8000-000000000026, 'user_015', 'rent', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_015', '2025-09', '2025-09-16 09:55:00+0000', 00000026-0000-1000-8000-000000000026, 'S011', 'Station Villeurbanne', 'rent', 'scooter');
APPLY BATCH;

-- Event 039
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S012', '2025-09-16', '2025-09-16 10:20:00+0000', 00000027-0000-1000-8000-000000000027, 'user_016', 'return', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_016', '2025-09', '2025-09-16 10:20:00+0000', 00000027-0000-1000-8000-000000000027, 'S012', 'Station Caluire', 'return', 'car');
APPLY BATCH;

-- Event 040
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S013', '2025-09-16', '2025-09-16 10:45:00+0000', 00000028-0000-1000-8000-000000000028, 'user_017', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_017', '2025-09', '2025-09-16 10:45:00+0000', 00000028-0000-1000-8000-000000000028, 'S013', 'Station Saint-Fons', 'rent', 'bike');
APPLY BATCH;

-- Event 041
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S014', '2025-09-16', '2025-09-16 11:10:00+0000', 00000029-0000-1000-8000-000000000029, 'user_018', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_018', '2025-09', '2025-09-16 11:10:00+0000', 00000029-0000-1000-8000-000000000029, 'S014', 'Station Vénissieux', 'return', 'bike');
APPLY BATCH;

-- Event 042
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S015', '2025-09-16', '2025-09-16 11:35:00+0000', 0000002a-0000-1000-8000-00000000002a, 'user_019', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_019', '2025-09', '2025-09-16 11:35:00+0000', 0000002a-0000-1000-8000-00000000002a, 'S015', 'Station Bron', 'rent', 'bike');
APPLY BATCH;

-- Event 043
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S001', '2025-09-16', '2025-09-16 12:00:00+0000', 0000002b-0000-1000-8000-00000000002b, 'user_020', 'return', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_020', '2025-09', '2025-09-16 12:00:00+0000', 0000002b-0000-1000-8000-00000000002b, 'S001', 'Station République', 'return', 'scooter');
APPLY BATCH;

-- Event 044
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S002', '2025-09-16', '2025-09-16 12:25:00+0000', 0000002c-0000-1000-8000-00000000002c, 'user_021', 'rent', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_021', '2025-09', '2025-09-16 12:25:00+0000', 0000002c-0000-1000-8000-00000000002c, 'S002', 'Station Bellecour', 'rent', 'car');
APPLY BATCH;

-- Event 045
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S003', '2025-09-16', '2025-09-16 12:50:00+0000', 0000002d-0000-1000-8000-00000000002d, 'user_022', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_022', '2025-09', '2025-09-16 12:50:00+0000', 0000002d-0000-1000-8000-00000000002d, 'S003', 'Station Confluence', 'return', 'bike');
APPLY BATCH;

-- Event 046
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S004', '2025-09-16', '2025-09-16 13:15:00+0000', 0000002e-0000-1000-8000-00000000002e, 'user_023', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_023', '2025-09', '2025-09-16 13:15:00+0000', 0000002e-0000-1000-8000-00000000002e, 'S004', 'Station Perrache', 'rent', 'bike');
APPLY BATCH;

-- Event 047
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S005', '2025-09-16', '2025-09-16 13:40:00+0000', 0000002f-0000-1000-8000-00000000002f, 'user_024', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_024', '2025-09', '2025-09-16 13:40:00+0000', 0000002f-0000-1000-8000-00000000002f, 'S005', 'Station Part-Dieu', 'return', 'bike');
APPLY BATCH;

-- Event 048
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S006', '2025-09-16', '2025-09-16 14:05:00+0000', 00000030-0000-1000-8000-000000000030, 'user_025', 'rent', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_025', '2025-09', '2025-09-16 14:05:00+0000', 00000030-0000-1000-8000-000000000030, 'S006', 'Station Vieux-Lyon', 'rent', 'scooter');
APPLY BATCH;

-- Event 049
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S007', '2025-09-16', '2025-09-16 14:30:00+0000', 00000031-0000-1000-8000-000000000031, 'user_026', 'return', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_026', '2025-09', '2025-09-16 14:30:00+0000', 00000031-0000-1000-8000-000000000031, 'S007', 'Station Croix-Rousse', 'return', 'car');
APPLY BATCH;

-- Event 050
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S008', '2025-09-16', '2025-09-16 14:55:00+0000', 00000032-0000-1000-8000-000000000032, 'user_027', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_027', '2025-09', '2025-09-16 14:55:00+0000', 00000032-0000-1000-8000-000000000032, 'S008', 'Station Monplaisir', 'rent', 'bike');
APPLY BATCH;

-- Event 051
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S009', '2025-09-16', '2025-09-16 15:20:00+0000', 00000033-0000-1000-8000-000000000033, 'user_028', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_028', '2025-09', '2025-09-16 15:20:00+0000', 00000033-0000-1000-8000-000000000033, 'S009', 'Station Brotteaux', 'return', 'bike');
APPLY BATCH;

-- Event 052
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S010', '2025-09-16', '2025-09-16 15:45:00+0000', 00000034-0000-1000-8000-000000000034, 'user_029', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_029', '2025-09', '2025-09-16 15:45:00+0000', 00000034-0000-1000-8000-000000000034, 'S010', 'Station Gerland', 'rent', 'bike');
APPLY BATCH;

-- Event 053
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S011', '2025-09-16', '2025-09-16 16:10:00+0000', 00000035-0000-1000-8000-000000000035, 'user_030', 'return', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_030', '2025-09', '2025-09-16 16:10:00+0000', 00000035-0000-1000-8000-000000000035, 'S011', 'Station Villeurbanne', 'return', 'scooter');
APPLY BATCH;

-- Event 054
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S012', '2025-09-16', '2025-09-16 16:35:00+0000', 00000036-0000-1000-8000-000000000036, 'user_001', 'rent', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_001', '2025-09', '2025-09-16 16:35:00+0000', 00000036-0000-1000-8000-000000000036, 'S012', 'Station Caluire', 'rent', 'car');
APPLY BATCH;

-- Event 055
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S013', '2025-09-16', '2025-09-16 17:00:00+0000', 00000037-0000-1000-8000-000000000037, 'user_002', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_002', '2025-09', '2025-09-16 17:00:00+0000', 00000037-0000-1000-8000-000000000037, 'S013', 'Station Saint-Fons', 'return', 'bike');
APPLY BATCH;

-- Event 056
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S014', '2025-09-16', '2025-09-16 17:25:00+0000', 00000038-0000-1000-8000-000000000038, 'user_003', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_003', '2025-09', '2025-09-16 17:25:00+0000', 00000038-0000-1000-8000-000000000038, 'S014', 'Station Vénissieux', 'rent', 'bike');
APPLY BATCH;

-- Event 057
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S015', '2025-09-16', '2025-09-16 17:50:00+0000', 00000039-0000-1000-8000-000000000039, 'user_004', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_004', '2025-09', '2025-09-16 17:50:00+0000', 00000039-0000-1000-8000-000000000039, 'S015', 'Station Bron', 'return', 'bike');
APPLY BATCH;

-- Event 058
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S001', '2025-09-16', '2025-09-16 18:15:00+0000', 0000003a-0000-1000-8000-00000000003a, 'user_005', 'rent', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_005', '2025-09', '2025-09-16 18:15:00+0000', 0000003a-0000-1000-8000-00000000003a, 'S001', 'Station République', 'rent', 'scooter');
APPLY BATCH;

-- Event 059
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S002', '2025-09-16', '2025-09-16 18:40:00+0000', 0000003b-0000-1000-8000-00000000003b, 'user_006', 'return', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_006', '2025-09', '2025-09-16 18:40:00+0000', 0000003b-0000-1000-8000-00000000003b, 'S002', 'Station Bellecour', 'return', 'car');
APPLY BATCH;

-- Event 060
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S003', '2025-09-16', '2025-09-16 19:05:00+0000', 0000003c-0000-1000-8000-00000000003c, 'user_007', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_007', '2025-09', '2025-09-16 19:05:00+0000', 0000003c-0000-1000-8000-00000000003c, 'S003', 'Station Confluence', 'rent', 'bike');
APPLY BATCH;


-- ============================================================
-- JOUR 2025-09-17
-- ============================================================

-- Event 061
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S007', '2025-09-17', '2025-09-17 07:00:00+0000', 0000003d-0000-1000-8000-00000000003d, 'user_015', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_015', '2025-09', '2025-09-17 07:00:00+0000', 0000003d-0000-1000-8000-00000000003d, 'S007', 'Station Croix-Rousse', 'rent', 'bike');
APPLY BATCH;

-- Event 062
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S008', '2025-09-17', '2025-09-17 07:25:00+0000', 0000003e-0000-1000-8000-00000000003e, 'user_016', 'return', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_016', '2025-09', '2025-09-17 07:25:00+0000', 0000003e-0000-1000-8000-00000000003e, 'S008', 'Station Monplaisir', 'return', 'scooter');
APPLY BATCH;

-- Event 063
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S009', '2025-09-17', '2025-09-17 07:50:00+0000', 0000003f-0000-1000-8000-00000000003f, 'user_017', 'rent', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_017', '2025-09', '2025-09-17 07:50:00+0000', 0000003f-0000-1000-8000-00000000003f, 'S009', 'Station Brotteaux', 'rent', 'car');
APPLY BATCH;

-- Event 064
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S010', '2025-09-17', '2025-09-17 08:15:00+0000', 00000040-0000-1000-8000-000000000040, 'user_018', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_018', '2025-09', '2025-09-17 08:15:00+0000', 00000040-0000-1000-8000-000000000040, 'S010', 'Station Gerland', 'return', 'bike');
APPLY BATCH;

-- Event 065
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S011', '2025-09-17', '2025-09-17 08:40:00+0000', 00000041-0000-1000-8000-000000000041, 'user_019', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_019', '2025-09', '2025-09-17 08:40:00+0000', 00000041-0000-1000-8000-000000000041, 'S011', 'Station Villeurbanne', 'rent', 'bike');
APPLY BATCH;

-- Event 066
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S012', '2025-09-17', '2025-09-17 09:05:00+0000', 00000042-0000-1000-8000-000000000042, 'user_020', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_020', '2025-09', '2025-09-17 09:05:00+0000', 00000042-0000-1000-8000-000000000042, 'S012', 'Station Caluire', 'return', 'bike');
APPLY BATCH;

-- Event 067
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S013', '2025-09-17', '2025-09-17 09:30:00+0000', 00000043-0000-1000-8000-000000000043, 'user_021', 'rent', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_021', '2025-09', '2025-09-17 09:30:00+0000', 00000043-0000-1000-8000-000000000043, 'S013', 'Station Saint-Fons', 'rent', 'scooter');
APPLY BATCH;

-- Event 068
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S014', '2025-09-17', '2025-09-17 09:55:00+0000', 00000044-0000-1000-8000-000000000044, 'user_022', 'return', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_022', '2025-09', '2025-09-17 09:55:00+0000', 00000044-0000-1000-8000-000000000044, 'S014', 'Station Vénissieux', 'return', 'car');
APPLY BATCH;

-- Event 069
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S015', '2025-09-17', '2025-09-17 10:20:00+0000', 00000045-0000-1000-8000-000000000045, 'user_023', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_023', '2025-09', '2025-09-17 10:20:00+0000', 00000045-0000-1000-8000-000000000045, 'S015', 'Station Bron', 'rent', 'bike');
APPLY BATCH;

-- Event 070
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S001', '2025-09-17', '2025-09-17 10:45:00+0000', 00000046-0000-1000-8000-000000000046, 'user_024', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_024', '2025-09', '2025-09-17 10:45:00+0000', 00000046-0000-1000-8000-000000000046, 'S001', 'Station République', 'return', 'bike');
APPLY BATCH;

-- Event 071
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S002', '2025-09-17', '2025-09-17 11:10:00+0000', 00000047-0000-1000-8000-000000000047, 'user_025', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_025', '2025-09', '2025-09-17 11:10:00+0000', 00000047-0000-1000-8000-000000000047, 'S002', 'Station Bellecour', 'rent', 'bike');
APPLY BATCH;

-- Event 072
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S003', '2025-09-17', '2025-09-17 11:35:00+0000', 00000048-0000-1000-8000-000000000048, 'user_026', 'return', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_026', '2025-09', '2025-09-17 11:35:00+0000', 00000048-0000-1000-8000-000000000048, 'S003', 'Station Confluence', 'return', 'scooter');
APPLY BATCH;

-- Event 073
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S004', '2025-09-17', '2025-09-17 12:00:00+0000', 00000049-0000-1000-8000-000000000049, 'user_027', 'rent', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_027', '2025-09', '2025-09-17 12:00:00+0000', 00000049-0000-1000-8000-000000000049, 'S004', 'Station Perrache', 'rent', 'car');
APPLY BATCH;

-- Event 074
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S005', '2025-09-17', '2025-09-17 12:25:00+0000', 0000004a-0000-1000-8000-00000000004a, 'user_028', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_028', '2025-09', '2025-09-17 12:25:00+0000', 0000004a-0000-1000-8000-00000000004a, 'S005', 'Station Part-Dieu', 'return', 'bike');
APPLY BATCH;

-- Event 075
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S006', '2025-09-17', '2025-09-17 12:50:00+0000', 0000004b-0000-1000-8000-00000000004b, 'user_029', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_029', '2025-09', '2025-09-17 12:50:00+0000', 0000004b-0000-1000-8000-00000000004b, 'S006', 'Station Vieux-Lyon', 'rent', 'bike');
APPLY BATCH;

-- Event 076
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S007', '2025-09-17', '2025-09-17 13:15:00+0000', 0000004c-0000-1000-8000-00000000004c, 'user_030', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_030', '2025-09', '2025-09-17 13:15:00+0000', 0000004c-0000-1000-8000-00000000004c, 'S007', 'Station Croix-Rousse', 'return', 'bike');
APPLY BATCH;

-- Event 077
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S008', '2025-09-17', '2025-09-17 13:40:00+0000', 0000004d-0000-1000-8000-00000000004d, 'user_001', 'rent', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_001', '2025-09', '2025-09-17 13:40:00+0000', 0000004d-0000-1000-8000-00000000004d, 'S008', 'Station Monplaisir', 'rent', 'scooter');
APPLY BATCH;

-- Event 078
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S009', '2025-09-17', '2025-09-17 14:05:00+0000', 0000004e-0000-1000-8000-00000000004e, 'user_002', 'return', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_002', '2025-09', '2025-09-17 14:05:00+0000', 0000004e-0000-1000-8000-00000000004e, 'S009', 'Station Brotteaux', 'return', 'car');
APPLY BATCH;

-- Event 079
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S010', '2025-09-17', '2025-09-17 14:30:00+0000', 0000004f-0000-1000-8000-00000000004f, 'user_003', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_003', '2025-09', '2025-09-17 14:30:00+0000', 0000004f-0000-1000-8000-00000000004f, 'S010', 'Station Gerland', 'rent', 'bike');
APPLY BATCH;

-- Event 080
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S011', '2025-09-17', '2025-09-17 14:55:00+0000', 00000050-0000-1000-8000-000000000050, 'user_004', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_004', '2025-09', '2025-09-17 14:55:00+0000', 00000050-0000-1000-8000-000000000050, 'S011', 'Station Villeurbanne', 'return', 'bike');
APPLY BATCH;

-- Event 081
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S012', '2025-09-17', '2025-09-17 15:20:00+0000', 00000051-0000-1000-8000-000000000051, 'user_005', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_005', '2025-09', '2025-09-17 15:20:00+0000', 00000051-0000-1000-8000-000000000051, 'S012', 'Station Caluire', 'rent', 'bike');
APPLY BATCH;

-- Event 082
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S013', '2025-09-17', '2025-09-17 15:45:00+0000', 00000052-0000-1000-8000-000000000052, 'user_006', 'return', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_006', '2025-09', '2025-09-17 15:45:00+0000', 00000052-0000-1000-8000-000000000052, 'S013', 'Station Saint-Fons', 'return', 'scooter');
APPLY BATCH;

-- Event 083
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S014', '2025-09-17', '2025-09-17 16:10:00+0000', 00000053-0000-1000-8000-000000000053, 'user_007', 'rent', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_007', '2025-09', '2025-09-17 16:10:00+0000', 00000053-0000-1000-8000-000000000053, 'S014', 'Station Vénissieux', 'rent', 'car');
APPLY BATCH;

-- Event 084
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S015', '2025-09-17', '2025-09-17 16:35:00+0000', 00000054-0000-1000-8000-000000000054, 'user_008', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_008', '2025-09', '2025-09-17 16:35:00+0000', 00000054-0000-1000-8000-000000000054, 'S015', 'Station Bron', 'return', 'bike');
APPLY BATCH;

-- Event 085
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S001', '2025-09-17', '2025-09-17 17:00:00+0000', 00000055-0000-1000-8000-000000000055, 'user_009', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_009', '2025-09', '2025-09-17 17:00:00+0000', 00000055-0000-1000-8000-000000000055, 'S001', 'Station République', 'rent', 'bike');
APPLY BATCH;

-- Event 086
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S002', '2025-09-17', '2025-09-17 17:25:00+0000', 00000056-0000-1000-8000-000000000056, 'user_010', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_010', '2025-09', '2025-09-17 17:25:00+0000', 00000056-0000-1000-8000-000000000056, 'S002', 'Station Bellecour', 'return', 'bike');
APPLY BATCH;

-- Event 087
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S003', '2025-09-17', '2025-09-17 17:50:00+0000', 00000057-0000-1000-8000-000000000057, 'user_011', 'rent', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_011', '2025-09', '2025-09-17 17:50:00+0000', 00000057-0000-1000-8000-000000000057, 'S003', 'Station Confluence', 'rent', 'scooter');
APPLY BATCH;

-- Event 088
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S004', '2025-09-17', '2025-09-17 18:15:00+0000', 00000058-0000-1000-8000-000000000058, 'user_012', 'return', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_012', '2025-09', '2025-09-17 18:15:00+0000', 00000058-0000-1000-8000-000000000058, 'S004', 'Station Perrache', 'return', 'car');
APPLY BATCH;

-- Event 089
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S005', '2025-09-17', '2025-09-17 18:40:00+0000', 00000059-0000-1000-8000-000000000059, 'user_013', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_013', '2025-09', '2025-09-17 18:40:00+0000', 00000059-0000-1000-8000-000000000059, 'S005', 'Station Part-Dieu', 'rent', 'bike');
APPLY BATCH;

-- Event 090
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S006', '2025-09-17', '2025-09-17 19:05:00+0000', 0000005a-0000-1000-8000-00000000005a, 'user_014', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_014', '2025-09', '2025-09-17 19:05:00+0000', 0000005a-0000-1000-8000-00000000005a, 'S006', 'Station Vieux-Lyon', 'return', 'bike');
APPLY BATCH;


-- ============================================================
-- JOUR 2025-09-18
-- ============================================================

-- Event 091
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S010', '2025-09-18', '2025-09-18 07:00:00+0000', 0000005b-0000-1000-8000-00000000005b, 'user_022', 'return', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_022', '2025-09', '2025-09-18 07:00:00+0000', 0000005b-0000-1000-8000-00000000005b, 'S010', 'Station Gerland', 'return', 'scooter');
APPLY BATCH;

-- Event 092
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S011', '2025-09-18', '2025-09-18 07:25:00+0000', 0000005c-0000-1000-8000-00000000005c, 'user_023', 'rent', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_023', '2025-09', '2025-09-18 07:25:00+0000', 0000005c-0000-1000-8000-00000000005c, 'S011', 'Station Villeurbanne', 'rent', 'car');
APPLY BATCH;

-- Event 093
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S012', '2025-09-18', '2025-09-18 07:50:00+0000', 0000005d-0000-1000-8000-00000000005d, 'user_024', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_024', '2025-09', '2025-09-18 07:50:00+0000', 0000005d-0000-1000-8000-00000000005d, 'S012', 'Station Caluire', 'return', 'bike');
APPLY BATCH;

-- Event 094
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S013', '2025-09-18', '2025-09-18 08:15:00+0000', 0000005e-0000-1000-8000-00000000005e, 'user_025', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_025', '2025-09', '2025-09-18 08:15:00+0000', 0000005e-0000-1000-8000-00000000005e, 'S013', 'Station Saint-Fons', 'rent', 'bike');
APPLY BATCH;

-- Event 095
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S014', '2025-09-18', '2025-09-18 08:40:00+0000', 0000005f-0000-1000-8000-00000000005f, 'user_026', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_026', '2025-09', '2025-09-18 08:40:00+0000', 0000005f-0000-1000-8000-00000000005f, 'S014', 'Station Vénissieux', 'return', 'bike');
APPLY BATCH;

-- Event 096
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S015', '2025-09-18', '2025-09-18 09:05:00+0000', 00000060-0000-1000-8000-000000000060, 'user_027', 'rent', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_027', '2025-09', '2025-09-18 09:05:00+0000', 00000060-0000-1000-8000-000000000060, 'S015', 'Station Bron', 'rent', 'scooter');
APPLY BATCH;

-- Event 097
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S001', '2025-09-18', '2025-09-18 09:30:00+0000', 00000061-0000-1000-8000-000000000061, 'user_028', 'return', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_028', '2025-09', '2025-09-18 09:30:00+0000', 00000061-0000-1000-8000-000000000061, 'S001', 'Station République', 'return', 'car');
APPLY BATCH;

-- Event 098
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S002', '2025-09-18', '2025-09-18 09:55:00+0000', 00000062-0000-1000-8000-000000000062, 'user_029', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_029', '2025-09', '2025-09-18 09:55:00+0000', 00000062-0000-1000-8000-000000000062, 'S002', 'Station Bellecour', 'rent', 'bike');
APPLY BATCH;

-- Event 099
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S003', '2025-09-18', '2025-09-18 10:20:00+0000', 00000063-0000-1000-8000-000000000063, 'user_030', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_030', '2025-09', '2025-09-18 10:20:00+0000', 00000063-0000-1000-8000-000000000063, 'S003', 'Station Confluence', 'return', 'bike');
APPLY BATCH;

-- Event 100
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S004', '2025-09-18', '2025-09-18 10:45:00+0000', 00000064-0000-1000-8000-000000000064, 'user_001', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_001', '2025-09', '2025-09-18 10:45:00+0000', 00000064-0000-1000-8000-000000000064, 'S004', 'Station Perrache', 'rent', 'bike');
APPLY BATCH;

-- Event 101
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S005', '2025-09-18', '2025-09-18 11:10:00+0000', 00000065-0000-1000-8000-000000000065, 'user_002', 'return', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_002', '2025-09', '2025-09-18 11:10:00+0000', 00000065-0000-1000-8000-000000000065, 'S005', 'Station Part-Dieu', 'return', 'scooter');
APPLY BATCH;

-- Event 102
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S006', '2025-09-18', '2025-09-18 11:35:00+0000', 00000066-0000-1000-8000-000000000066, 'user_003', 'rent', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_003', '2025-09', '2025-09-18 11:35:00+0000', 00000066-0000-1000-8000-000000000066, 'S006', 'Station Vieux-Lyon', 'rent', 'car');
APPLY BATCH;

-- Event 103
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S007', '2025-09-18', '2025-09-18 12:00:00+0000', 00000067-0000-1000-8000-000000000067, 'user_004', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_004', '2025-09', '2025-09-18 12:00:00+0000', 00000067-0000-1000-8000-000000000067, 'S007', 'Station Croix-Rousse', 'return', 'bike');
APPLY BATCH;

-- Event 104
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S008', '2025-09-18', '2025-09-18 12:25:00+0000', 00000068-0000-1000-8000-000000000068, 'user_005', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_005', '2025-09', '2025-09-18 12:25:00+0000', 00000068-0000-1000-8000-000000000068, 'S008', 'Station Monplaisir', 'rent', 'bike');
APPLY BATCH;

-- Event 105
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S009', '2025-09-18', '2025-09-18 12:50:00+0000', 00000069-0000-1000-8000-000000000069, 'user_006', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_006', '2025-09', '2025-09-18 12:50:00+0000', 00000069-0000-1000-8000-000000000069, 'S009', 'Station Brotteaux', 'return', 'bike');
APPLY BATCH;

-- Event 106
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S010', '2025-09-18', '2025-09-18 13:15:00+0000', 0000006a-0000-1000-8000-00000000006a, 'user_007', 'rent', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_007', '2025-09', '2025-09-18 13:15:00+0000', 0000006a-0000-1000-8000-00000000006a, 'S010', 'Station Gerland', 'rent', 'scooter');
APPLY BATCH;

-- Event 107
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S011', '2025-09-18', '2025-09-18 13:40:00+0000', 0000006b-0000-1000-8000-00000000006b, 'user_008', 'return', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_008', '2025-09', '2025-09-18 13:40:00+0000', 0000006b-0000-1000-8000-00000000006b, 'S011', 'Station Villeurbanne', 'return', 'car');
APPLY BATCH;

-- Event 108
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S012', '2025-09-18', '2025-09-18 14:05:00+0000', 0000006c-0000-1000-8000-00000000006c, 'user_009', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_009', '2025-09', '2025-09-18 14:05:00+0000', 0000006c-0000-1000-8000-00000000006c, 'S012', 'Station Caluire', 'rent', 'bike');
APPLY BATCH;

-- Event 109
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S013', '2025-09-18', '2025-09-18 14:30:00+0000', 0000006d-0000-1000-8000-00000000006d, 'user_010', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_010', '2025-09', '2025-09-18 14:30:00+0000', 0000006d-0000-1000-8000-00000000006d, 'S013', 'Station Saint-Fons', 'return', 'bike');
APPLY BATCH;

-- Event 110
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S014', '2025-09-18', '2025-09-18 14:55:00+0000', 0000006e-0000-1000-8000-00000000006e, 'user_011', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_011', '2025-09', '2025-09-18 14:55:00+0000', 0000006e-0000-1000-8000-00000000006e, 'S014', 'Station Vénissieux', 'rent', 'bike');
APPLY BATCH;

-- Event 111
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S015', '2025-09-18', '2025-09-18 15:20:00+0000', 0000006f-0000-1000-8000-00000000006f, 'user_012', 'return', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_012', '2025-09', '2025-09-18 15:20:00+0000', 0000006f-0000-1000-8000-00000000006f, 'S015', 'Station Bron', 'return', 'scooter');
APPLY BATCH;

-- Event 112
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S001', '2025-09-18', '2025-09-18 15:45:00+0000', 00000070-0000-1000-8000-000000000070, 'user_013', 'rent', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_013', '2025-09', '2025-09-18 15:45:00+0000', 00000070-0000-1000-8000-000000000070, 'S001', 'Station République', 'rent', 'car');
APPLY BATCH;

-- Event 113
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S002', '2025-09-18', '2025-09-18 16:10:00+0000', 00000071-0000-1000-8000-000000000071, 'user_014', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_014', '2025-09', '2025-09-18 16:10:00+0000', 00000071-0000-1000-8000-000000000071, 'S002', 'Station Bellecour', 'return', 'bike');
APPLY BATCH;

-- Event 114
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S003', '2025-09-18', '2025-09-18 16:35:00+0000', 00000072-0000-1000-8000-000000000072, 'user_015', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_015', '2025-09', '2025-09-18 16:35:00+0000', 00000072-0000-1000-8000-000000000072, 'S003', 'Station Confluence', 'rent', 'bike');
APPLY BATCH;

-- Event 115
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S004', '2025-09-18', '2025-09-18 17:00:00+0000', 00000073-0000-1000-8000-000000000073, 'user_016', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_016', '2025-09', '2025-09-18 17:00:00+0000', 00000073-0000-1000-8000-000000000073, 'S004', 'Station Perrache', 'return', 'bike');
APPLY BATCH;

-- Event 116
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S005', '2025-09-18', '2025-09-18 17:25:00+0000', 00000074-0000-1000-8000-000000000074, 'user_017', 'rent', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_017', '2025-09', '2025-09-18 17:25:00+0000', 00000074-0000-1000-8000-000000000074, 'S005', 'Station Part-Dieu', 'rent', 'scooter');
APPLY BATCH;

-- Event 117
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S006', '2025-09-18', '2025-09-18 17:50:00+0000', 00000075-0000-1000-8000-000000000075, 'user_018', 'return', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_018', '2025-09', '2025-09-18 17:50:00+0000', 00000075-0000-1000-8000-000000000075, 'S006', 'Station Vieux-Lyon', 'return', 'car');
APPLY BATCH;

-- Event 118
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S007', '2025-09-18', '2025-09-18 18:15:00+0000', 00000076-0000-1000-8000-000000000076, 'user_019', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_019', '2025-09', '2025-09-18 18:15:00+0000', 00000076-0000-1000-8000-000000000076, 'S007', 'Station Croix-Rousse', 'rent', 'bike');
APPLY BATCH;

-- Event 119
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S008', '2025-09-18', '2025-09-18 18:40:00+0000', 00000077-0000-1000-8000-000000000077, 'user_020', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_020', '2025-09', '2025-09-18 18:40:00+0000', 00000077-0000-1000-8000-000000000077, 'S008', 'Station Monplaisir', 'return', 'bike');
APPLY BATCH;

-- Event 120
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S009', '2025-09-18', '2025-09-18 19:05:00+0000', 00000078-0000-1000-8000-000000000078, 'user_021', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_021', '2025-09', '2025-09-18 19:05:00+0000', 00000078-0000-1000-8000-000000000078, 'S009', 'Station Brotteaux', 'rent', 'bike');
APPLY BATCH;


-- ============================================================
-- JOUR 2025-09-19
-- ============================================================

-- Event 121
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S013', '2025-09-19', '2025-09-19 07:00:00+0000', 00000079-0000-1000-8000-000000000079, 'user_029', 'rent', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_029', '2025-09', '2025-09-19 07:00:00+0000', 00000079-0000-1000-8000-000000000079, 'S013', 'Station Saint-Fons', 'rent', 'car');
APPLY BATCH;

-- Event 122
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S014', '2025-09-19', '2025-09-19 07:25:00+0000', 0000007a-0000-1000-8000-00000000007a, 'user_030', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_030', '2025-09', '2025-09-19 07:25:00+0000', 0000007a-0000-1000-8000-00000000007a, 'S014', 'Station Vénissieux', 'return', 'bike');
APPLY BATCH;

-- Event 123
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S015', '2025-09-19', '2025-09-19 07:50:00+0000', 0000007b-0000-1000-8000-00000000007b, 'user_001', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_001', '2025-09', '2025-09-19 07:50:00+0000', 0000007b-0000-1000-8000-00000000007b, 'S015', 'Station Bron', 'rent', 'bike');
APPLY BATCH;

-- Event 124
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S001', '2025-09-19', '2025-09-19 08:15:00+0000', 0000007c-0000-1000-8000-00000000007c, 'user_002', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_002', '2025-09', '2025-09-19 08:15:00+0000', 0000007c-0000-1000-8000-00000000007c, 'S001', 'Station République', 'return', 'bike');
APPLY BATCH;

-- Event 125
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S002', '2025-09-19', '2025-09-19 08:40:00+0000', 0000007d-0000-1000-8000-00000000007d, 'user_003', 'rent', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_003', '2025-09', '2025-09-19 08:40:00+0000', 0000007d-0000-1000-8000-00000000007d, 'S002', 'Station Bellecour', 'rent', 'scooter');
APPLY BATCH;

-- Event 126
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S003', '2025-09-19', '2025-09-19 09:05:00+0000', 0000007e-0000-1000-8000-00000000007e, 'user_004', 'return', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_004', '2025-09', '2025-09-19 09:05:00+0000', 0000007e-0000-1000-8000-00000000007e, 'S003', 'Station Confluence', 'return', 'car');
APPLY BATCH;

-- Event 127
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S004', '2025-09-19', '2025-09-19 09:30:00+0000', 0000007f-0000-1000-8000-00000000007f, 'user_005', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_005', '2025-09', '2025-09-19 09:30:00+0000', 0000007f-0000-1000-8000-00000000007f, 'S004', 'Station Perrache', 'rent', 'bike');
APPLY BATCH;

-- Event 128
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S005', '2025-09-19', '2025-09-19 09:55:00+0000', 00000080-0000-1000-8000-000000000080, 'user_006', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_006', '2025-09', '2025-09-19 09:55:00+0000', 00000080-0000-1000-8000-000000000080, 'S005', 'Station Part-Dieu', 'return', 'bike');
APPLY BATCH;

-- Event 129
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S006', '2025-09-19', '2025-09-19 10:20:00+0000', 00000081-0000-1000-8000-000000000081, 'user_007', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_007', '2025-09', '2025-09-19 10:20:00+0000', 00000081-0000-1000-8000-000000000081, 'S006', 'Station Vieux-Lyon', 'rent', 'bike');
APPLY BATCH;

-- Event 130
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S007', '2025-09-19', '2025-09-19 10:45:00+0000', 00000082-0000-1000-8000-000000000082, 'user_008', 'return', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_008', '2025-09', '2025-09-19 10:45:00+0000', 00000082-0000-1000-8000-000000000082, 'S007', 'Station Croix-Rousse', 'return', 'scooter');
APPLY BATCH;

-- Event 131
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S008', '2025-09-19', '2025-09-19 11:10:00+0000', 00000083-0000-1000-8000-000000000083, 'user_009', 'rent', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_009', '2025-09', '2025-09-19 11:10:00+0000', 00000083-0000-1000-8000-000000000083, 'S008', 'Station Monplaisir', 'rent', 'car');
APPLY BATCH;

-- Event 132
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S009', '2025-09-19', '2025-09-19 11:35:00+0000', 00000084-0000-1000-8000-000000000084, 'user_010', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_010', '2025-09', '2025-09-19 11:35:00+0000', 00000084-0000-1000-8000-000000000084, 'S009', 'Station Brotteaux', 'return', 'bike');
APPLY BATCH;

-- Event 133
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S010', '2025-09-19', '2025-09-19 12:00:00+0000', 00000085-0000-1000-8000-000000000085, 'user_011', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_011', '2025-09', '2025-09-19 12:00:00+0000', 00000085-0000-1000-8000-000000000085, 'S010', 'Station Gerland', 'rent', 'bike');
APPLY BATCH;

-- Event 134
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S011', '2025-09-19', '2025-09-19 12:25:00+0000', 00000086-0000-1000-8000-000000000086, 'user_012', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_012', '2025-09', '2025-09-19 12:25:00+0000', 00000086-0000-1000-8000-000000000086, 'S011', 'Station Villeurbanne', 'return', 'bike');
APPLY BATCH;

-- Event 135
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S012', '2025-09-19', '2025-09-19 12:50:00+0000', 00000087-0000-1000-8000-000000000087, 'user_013', 'rent', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_013', '2025-09', '2025-09-19 12:50:00+0000', 00000087-0000-1000-8000-000000000087, 'S012', 'Station Caluire', 'rent', 'scooter');
APPLY BATCH;

-- Event 136
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S013', '2025-09-19', '2025-09-19 13:15:00+0000', 00000088-0000-1000-8000-000000000088, 'user_014', 'return', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_014', '2025-09', '2025-09-19 13:15:00+0000', 00000088-0000-1000-8000-000000000088, 'S013', 'Station Saint-Fons', 'return', 'car');
APPLY BATCH;

-- Event 137
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S014', '2025-09-19', '2025-09-19 13:40:00+0000', 00000089-0000-1000-8000-000000000089, 'user_015', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_015', '2025-09', '2025-09-19 13:40:00+0000', 00000089-0000-1000-8000-000000000089, 'S014', 'Station Vénissieux', 'rent', 'bike');
APPLY BATCH;

-- Event 138
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S015', '2025-09-19', '2025-09-19 14:05:00+0000', 0000008a-0000-1000-8000-00000000008a, 'user_016', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_016', '2025-09', '2025-09-19 14:05:00+0000', 0000008a-0000-1000-8000-00000000008a, 'S015', 'Station Bron', 'return', 'bike');
APPLY BATCH;

-- Event 139
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S001', '2025-09-19', '2025-09-19 14:30:00+0000', 0000008b-0000-1000-8000-00000000008b, 'user_017', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_017', '2025-09', '2025-09-19 14:30:00+0000', 0000008b-0000-1000-8000-00000000008b, 'S001', 'Station République', 'rent', 'bike');
APPLY BATCH;

-- Event 140
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S002', '2025-09-19', '2025-09-19 14:55:00+0000', 0000008c-0000-1000-8000-00000000008c, 'user_018', 'return', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_018', '2025-09', '2025-09-19 14:55:00+0000', 0000008c-0000-1000-8000-00000000008c, 'S002', 'Station Bellecour', 'return', 'scooter');
APPLY BATCH;

-- Event 141
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S003', '2025-09-19', '2025-09-19 15:20:00+0000', 0000008d-0000-1000-8000-00000000008d, 'user_019', 'rent', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_019', '2025-09', '2025-09-19 15:20:00+0000', 0000008d-0000-1000-8000-00000000008d, 'S003', 'Station Confluence', 'rent', 'car');
APPLY BATCH;

-- Event 142
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S004', '2025-09-19', '2025-09-19 15:45:00+0000', 0000008e-0000-1000-8000-00000000008e, 'user_020', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_020', '2025-09', '2025-09-19 15:45:00+0000', 0000008e-0000-1000-8000-00000000008e, 'S004', 'Station Perrache', 'return', 'bike');
APPLY BATCH;

-- Event 143
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S005', '2025-09-19', '2025-09-19 16:10:00+0000', 0000008f-0000-1000-8000-00000000008f, 'user_021', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_021', '2025-09', '2025-09-19 16:10:00+0000', 0000008f-0000-1000-8000-00000000008f, 'S005', 'Station Part-Dieu', 'rent', 'bike');
APPLY BATCH;

-- Event 144
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S006', '2025-09-19', '2025-09-19 16:35:00+0000', 00000090-0000-1000-8000-000000000090, 'user_022', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_022', '2025-09', '2025-09-19 16:35:00+0000', 00000090-0000-1000-8000-000000000090, 'S006', 'Station Vieux-Lyon', 'return', 'bike');
APPLY BATCH;

-- Event 145
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S007', '2025-09-19', '2025-09-19 17:00:00+0000', 00000091-0000-1000-8000-000000000091, 'user_023', 'rent', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_023', '2025-09', '2025-09-19 17:00:00+0000', 00000091-0000-1000-8000-000000000091, 'S007', 'Station Croix-Rousse', 'rent', 'scooter');
APPLY BATCH;


-- ============================================================
-- JOUR 2025-09-20
-- ============================================================

-- Event 146
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S001', '2025-09-20', '2025-09-20 07:00:00+0000', 00000092-0000-1000-8000-000000000092, 'user_006', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_006', '2025-09', '2025-09-20 07:00:00+0000', 00000092-0000-1000-8000-000000000092, 'S001', 'Station République', 'return', 'bike');
APPLY BATCH;

-- Event 147
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S002', '2025-09-20', '2025-09-20 07:25:00+0000', 00000093-0000-1000-8000-000000000093, 'user_007', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_007', '2025-09', '2025-09-20 07:25:00+0000', 00000093-0000-1000-8000-000000000093, 'S002', 'Station Bellecour', 'rent', 'bike');
APPLY BATCH;

-- Event 148
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S003', '2025-09-20', '2025-09-20 07:50:00+0000', 00000094-0000-1000-8000-000000000094, 'user_008', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_008', '2025-09', '2025-09-20 07:50:00+0000', 00000094-0000-1000-8000-000000000094, 'S003', 'Station Confluence', 'return', 'bike');
APPLY BATCH;

-- Event 149
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S004', '2025-09-20', '2025-09-20 08:15:00+0000', 00000095-0000-1000-8000-000000000095, 'user_009', 'rent', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_009', '2025-09', '2025-09-20 08:15:00+0000', 00000095-0000-1000-8000-000000000095, 'S004', 'Station Perrache', 'rent', 'scooter');
APPLY BATCH;

-- Event 150
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S005', '2025-09-20', '2025-09-20 08:40:00+0000', 00000096-0000-1000-8000-000000000096, 'user_010', 'return', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_010', '2025-09', '2025-09-20 08:40:00+0000', 00000096-0000-1000-8000-000000000096, 'S005', 'Station Part-Dieu', 'return', 'car');
APPLY BATCH;

-- Event 151
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S006', '2025-09-20', '2025-09-20 09:05:00+0000', 00000097-0000-1000-8000-000000000097, 'user_011', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_011', '2025-09', '2025-09-20 09:05:00+0000', 00000097-0000-1000-8000-000000000097, 'S006', 'Station Vieux-Lyon', 'rent', 'bike');
APPLY BATCH;

-- Event 152
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S007', '2025-09-20', '2025-09-20 09:30:00+0000', 00000098-0000-1000-8000-000000000098, 'user_012', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_012', '2025-09', '2025-09-20 09:30:00+0000', 00000098-0000-1000-8000-000000000098, 'S007', 'Station Croix-Rousse', 'return', 'bike');
APPLY BATCH;

-- Event 153
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S008', '2025-09-20', '2025-09-20 09:55:00+0000', 00000099-0000-1000-8000-000000000099, 'user_013', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_013', '2025-09', '2025-09-20 09:55:00+0000', 00000099-0000-1000-8000-000000000099, 'S008', 'Station Monplaisir', 'rent', 'bike');
APPLY BATCH;

-- Event 154
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S009', '2025-09-20', '2025-09-20 10:20:00+0000', 0000009a-0000-1000-8000-00000000009a, 'user_014', 'return', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_014', '2025-09', '2025-09-20 10:20:00+0000', 0000009a-0000-1000-8000-00000000009a, 'S009', 'Station Brotteaux', 'return', 'scooter');
APPLY BATCH;

-- Event 155
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S010', '2025-09-20', '2025-09-20 10:45:00+0000', 0000009b-0000-1000-8000-00000000009b, 'user_015', 'rent', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_015', '2025-09', '2025-09-20 10:45:00+0000', 0000009b-0000-1000-8000-00000000009b, 'S010', 'Station Gerland', 'rent', 'car');
APPLY BATCH;

-- Event 156
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S011', '2025-09-20', '2025-09-20 11:10:00+0000', 0000009c-0000-1000-8000-00000000009c, 'user_016', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_016', '2025-09', '2025-09-20 11:10:00+0000', 0000009c-0000-1000-8000-00000000009c, 'S011', 'Station Villeurbanne', 'return', 'bike');
APPLY BATCH;

-- Event 157
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S012', '2025-09-20', '2025-09-20 11:35:00+0000', 0000009d-0000-1000-8000-00000000009d, 'user_017', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_017', '2025-09', '2025-09-20 11:35:00+0000', 0000009d-0000-1000-8000-00000000009d, 'S012', 'Station Caluire', 'rent', 'bike');
APPLY BATCH;

-- Event 158
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S013', '2025-09-20', '2025-09-20 12:00:00+0000', 0000009e-0000-1000-8000-00000000009e, 'user_018', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_018', '2025-09', '2025-09-20 12:00:00+0000', 0000009e-0000-1000-8000-00000000009e, 'S013', 'Station Saint-Fons', 'return', 'bike');
APPLY BATCH;

-- Event 159
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S014', '2025-09-20', '2025-09-20 12:25:00+0000', 0000009f-0000-1000-8000-00000000009f, 'user_019', 'rent', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_019', '2025-09', '2025-09-20 12:25:00+0000', 0000009f-0000-1000-8000-00000000009f, 'S014', 'Station Vénissieux', 'rent', 'scooter');
APPLY BATCH;

-- Event 160
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S015', '2025-09-20', '2025-09-20 12:50:00+0000', 000000a0-0000-1000-8000-0000000000a0, 'user_020', 'return', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_020', '2025-09', '2025-09-20 12:50:00+0000', 000000a0-0000-1000-8000-0000000000a0, 'S015', 'Station Bron', 'return', 'car');
APPLY BATCH;

-- Event 161
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S001', '2025-09-20', '2025-09-20 13:15:00+0000', 000000a1-0000-1000-8000-0000000000a1, 'user_021', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_021', '2025-09', '2025-09-20 13:15:00+0000', 000000a1-0000-1000-8000-0000000000a1, 'S001', 'Station République', 'rent', 'bike');
APPLY BATCH;

-- Event 162
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S002', '2025-09-20', '2025-09-20 13:40:00+0000', 000000a2-0000-1000-8000-0000000000a2, 'user_022', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_022', '2025-09', '2025-09-20 13:40:00+0000', 000000a2-0000-1000-8000-0000000000a2, 'S002', 'Station Bellecour', 'return', 'bike');
APPLY BATCH;

-- Event 163
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S003', '2025-09-20', '2025-09-20 14:05:00+0000', 000000a3-0000-1000-8000-0000000000a3, 'user_023', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_023', '2025-09', '2025-09-20 14:05:00+0000', 000000a3-0000-1000-8000-0000000000a3, 'S003', 'Station Confluence', 'rent', 'bike');
APPLY BATCH;

-- Event 164
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S004', '2025-09-20', '2025-09-20 14:30:00+0000', 000000a4-0000-1000-8000-0000000000a4, 'user_024', 'return', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_024', '2025-09', '2025-09-20 14:30:00+0000', 000000a4-0000-1000-8000-0000000000a4, 'S004', 'Station Perrache', 'return', 'scooter');
APPLY BATCH;

-- Event 165
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S005', '2025-09-20', '2025-09-20 14:55:00+0000', 000000a5-0000-1000-8000-0000000000a5, 'user_025', 'rent', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_025', '2025-09', '2025-09-20 14:55:00+0000', 000000a5-0000-1000-8000-0000000000a5, 'S005', 'Station Part-Dieu', 'rent', 'car');
APPLY BATCH;

-- Event 166
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S006', '2025-09-20', '2025-09-20 15:20:00+0000', 000000a6-0000-1000-8000-0000000000a6, 'user_026', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_026', '2025-09', '2025-09-20 15:20:00+0000', 000000a6-0000-1000-8000-0000000000a6, 'S006', 'Station Vieux-Lyon', 'return', 'bike');
APPLY BATCH;

-- Event 167
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S007', '2025-09-20', '2025-09-20 15:45:00+0000', 000000a7-0000-1000-8000-0000000000a7, 'user_027', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_027', '2025-09', '2025-09-20 15:45:00+0000', 000000a7-0000-1000-8000-0000000000a7, 'S007', 'Station Croix-Rousse', 'rent', 'bike');
APPLY BATCH;

-- Event 168
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S008', '2025-09-20', '2025-09-20 16:10:00+0000', 000000a8-0000-1000-8000-0000000000a8, 'user_028', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_028', '2025-09', '2025-09-20 16:10:00+0000', 000000a8-0000-1000-8000-0000000000a8, 'S008', 'Station Monplaisir', 'return', 'bike');
APPLY BATCH;

-- Event 169
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S009', '2025-09-20', '2025-09-20 16:35:00+0000', 000000a9-0000-1000-8000-0000000000a9, 'user_029', 'rent', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_029', '2025-09', '2025-09-20 16:35:00+0000', 000000a9-0000-1000-8000-0000000000a9, 'S009', 'Station Brotteaux', 'rent', 'scooter');
APPLY BATCH;

-- Event 170
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S010', '2025-09-20', '2025-09-20 17:00:00+0000', 000000aa-0000-1000-8000-0000000000aa, 'user_030', 'return', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_030', '2025-09', '2025-09-20 17:00:00+0000', 000000aa-0000-1000-8000-0000000000aa, 'S010', 'Station Gerland', 'return', 'car');
APPLY BATCH;


-- ============================================================
-- JOUR 2025-09-21
-- ============================================================

-- Event 171
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S004', '2025-09-21', '2025-09-21 07:00:00+0000', 000000ab-0000-1000-8000-0000000000ab, 'user_013', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_013', '2025-09', '2025-09-21 07:00:00+0000', 000000ab-0000-1000-8000-0000000000ab, 'S004', 'Station Perrache', 'rent', 'bike');
APPLY BATCH;

-- Event 172
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S005', '2025-09-21', '2025-09-21 07:25:00+0000', 000000ac-0000-1000-8000-0000000000ac, 'user_014', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_014', '2025-09', '2025-09-21 07:25:00+0000', 000000ac-0000-1000-8000-0000000000ac, 'S005', 'Station Part-Dieu', 'return', 'bike');
APPLY BATCH;

-- Event 173
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S006', '2025-09-21', '2025-09-21 07:50:00+0000', 000000ad-0000-1000-8000-0000000000ad, 'user_015', 'rent', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_015', '2025-09', '2025-09-21 07:50:00+0000', 000000ad-0000-1000-8000-0000000000ad, 'S006', 'Station Vieux-Lyon', 'rent', 'scooter');
APPLY BATCH;

-- Event 174
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S007', '2025-09-21', '2025-09-21 08:15:00+0000', 000000ae-0000-1000-8000-0000000000ae, 'user_016', 'return', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_016', '2025-09', '2025-09-21 08:15:00+0000', 000000ae-0000-1000-8000-0000000000ae, 'S007', 'Station Croix-Rousse', 'return', 'car');
APPLY BATCH;

-- Event 175
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S008', '2025-09-21', '2025-09-21 08:40:00+0000', 000000af-0000-1000-8000-0000000000af, 'user_017', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_017', '2025-09', '2025-09-21 08:40:00+0000', 000000af-0000-1000-8000-0000000000af, 'S008', 'Station Monplaisir', 'rent', 'bike');
APPLY BATCH;

-- Event 176
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S009', '2025-09-21', '2025-09-21 09:05:00+0000', 000000b0-0000-1000-8000-0000000000b0, 'user_018', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_018', '2025-09', '2025-09-21 09:05:00+0000', 000000b0-0000-1000-8000-0000000000b0, 'S009', 'Station Brotteaux', 'return', 'bike');
APPLY BATCH;

-- Event 177
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S010', '2025-09-21', '2025-09-21 09:30:00+0000', 000000b1-0000-1000-8000-0000000000b1, 'user_019', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_019', '2025-09', '2025-09-21 09:30:00+0000', 000000b1-0000-1000-8000-0000000000b1, 'S010', 'Station Gerland', 'rent', 'bike');
APPLY BATCH;

-- Event 178
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S011', '2025-09-21', '2025-09-21 09:55:00+0000', 000000b2-0000-1000-8000-0000000000b2, 'user_020', 'return', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_020', '2025-09', '2025-09-21 09:55:00+0000', 000000b2-0000-1000-8000-0000000000b2, 'S011', 'Station Villeurbanne', 'return', 'scooter');
APPLY BATCH;

-- Event 179
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S012', '2025-09-21', '2025-09-21 10:20:00+0000', 000000b3-0000-1000-8000-0000000000b3, 'user_021', 'rent', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_021', '2025-09', '2025-09-21 10:20:00+0000', 000000b3-0000-1000-8000-0000000000b3, 'S012', 'Station Caluire', 'rent', 'car');
APPLY BATCH;

-- Event 180
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S013', '2025-09-21', '2025-09-21 10:45:00+0000', 000000b4-0000-1000-8000-0000000000b4, 'user_022', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_022', '2025-09', '2025-09-21 10:45:00+0000', 000000b4-0000-1000-8000-0000000000b4, 'S013', 'Station Saint-Fons', 'return', 'bike');
APPLY BATCH;

-- Event 181
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S014', '2025-09-21', '2025-09-21 11:10:00+0000', 000000b5-0000-1000-8000-0000000000b5, 'user_023', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_023', '2025-09', '2025-09-21 11:10:00+0000', 000000b5-0000-1000-8000-0000000000b5, 'S014', 'Station Vénissieux', 'rent', 'bike');
APPLY BATCH;

-- Event 182
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S015', '2025-09-21', '2025-09-21 11:35:00+0000', 000000b6-0000-1000-8000-0000000000b6, 'user_024', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_024', '2025-09', '2025-09-21 11:35:00+0000', 000000b6-0000-1000-8000-0000000000b6, 'S015', 'Station Bron', 'return', 'bike');
APPLY BATCH;

-- Event 183
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S001', '2025-09-21', '2025-09-21 12:00:00+0000', 000000b7-0000-1000-8000-0000000000b7, 'user_025', 'rent', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_025', '2025-09', '2025-09-21 12:00:00+0000', 000000b7-0000-1000-8000-0000000000b7, 'S001', 'Station République', 'rent', 'scooter');
APPLY BATCH;

-- Event 184
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S002', '2025-09-21', '2025-09-21 12:25:00+0000', 000000b8-0000-1000-8000-0000000000b8, 'user_026', 'return', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_026', '2025-09', '2025-09-21 12:25:00+0000', 000000b8-0000-1000-8000-0000000000b8, 'S002', 'Station Bellecour', 'return', 'car');
APPLY BATCH;

-- Event 185
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S003', '2025-09-21', '2025-09-21 12:50:00+0000', 000000b9-0000-1000-8000-0000000000b9, 'user_027', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_027', '2025-09', '2025-09-21 12:50:00+0000', 000000b9-0000-1000-8000-0000000000b9, 'S003', 'Station Confluence', 'rent', 'bike');
APPLY BATCH;

-- Event 186
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S004', '2025-09-21', '2025-09-21 13:15:00+0000', 000000ba-0000-1000-8000-0000000000ba, 'user_028', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_028', '2025-09', '2025-09-21 13:15:00+0000', 000000ba-0000-1000-8000-0000000000ba, 'S004', 'Station Perrache', 'return', 'bike');
APPLY BATCH;

-- Event 187
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S005', '2025-09-21', '2025-09-21 13:40:00+0000', 000000bb-0000-1000-8000-0000000000bb, 'user_029', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_029', '2025-09', '2025-09-21 13:40:00+0000', 000000bb-0000-1000-8000-0000000000bb, 'S005', 'Station Part-Dieu', 'rent', 'bike');
APPLY BATCH;

-- Event 188
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S006', '2025-09-21', '2025-09-21 14:05:00+0000', 000000bc-0000-1000-8000-0000000000bc, 'user_030', 'return', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_030', '2025-09', '2025-09-21 14:05:00+0000', 000000bc-0000-1000-8000-0000000000bc, 'S006', 'Station Vieux-Lyon', 'return', 'scooter');
APPLY BATCH;

-- Event 189
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S007', '2025-09-21', '2025-09-21 14:30:00+0000', 000000bd-0000-1000-8000-0000000000bd, 'user_001', 'rent', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_001', '2025-09', '2025-09-21 14:30:00+0000', 000000bd-0000-1000-8000-0000000000bd, 'S007', 'Station Croix-Rousse', 'rent', 'car');
APPLY BATCH;

-- Event 190
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S008', '2025-09-21', '2025-09-21 14:55:00+0000', 000000be-0000-1000-8000-0000000000be, 'user_002', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_002', '2025-09', '2025-09-21 14:55:00+0000', 000000be-0000-1000-8000-0000000000be, 'S008', 'Station Monplaisir', 'return', 'bike');
APPLY BATCH;

-- Event 191
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S009', '2025-09-21', '2025-09-21 15:20:00+0000', 000000bf-0000-1000-8000-0000000000bf, 'user_003', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_003', '2025-09', '2025-09-21 15:20:00+0000', 000000bf-0000-1000-8000-0000000000bf, 'S009', 'Station Brotteaux', 'rent', 'bike');
APPLY BATCH;

-- Event 192
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S010', '2025-09-21', '2025-09-21 15:45:00+0000', 000000c0-0000-1000-8000-0000000000c0, 'user_004', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_004', '2025-09', '2025-09-21 15:45:00+0000', 000000c0-0000-1000-8000-0000000000c0, 'S010', 'Station Gerland', 'return', 'bike');
APPLY BATCH;

-- Event 193
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S011', '2025-09-21', '2025-09-21 16:10:00+0000', 000000c1-0000-1000-8000-0000000000c1, 'user_005', 'rent', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_005', '2025-09', '2025-09-21 16:10:00+0000', 000000c1-0000-1000-8000-0000000000c1, 'S011', 'Station Villeurbanne', 'rent', 'scooter');
APPLY BATCH;

-- Event 194
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S012', '2025-09-21', '2025-09-21 16:35:00+0000', 000000c2-0000-1000-8000-0000000000c2, 'user_006', 'return', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_006', '2025-09', '2025-09-21 16:35:00+0000', 000000c2-0000-1000-8000-0000000000c2, 'S012', 'Station Caluire', 'return', 'car');
APPLY BATCH;

-- Event 195
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S013', '2025-09-21', '2025-09-21 17:00:00+0000', 000000c3-0000-1000-8000-0000000000c3, 'user_007', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_007', '2025-09', '2025-09-21 17:00:00+0000', 000000c3-0000-1000-8000-0000000000c3, 'S013', 'Station Saint-Fons', 'rent', 'bike');
APPLY BATCH;

-- Event 196
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S014', '2025-09-21', '2025-09-21 17:25:00+0000', 000000c4-0000-1000-8000-0000000000c4, 'user_008', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_008', '2025-09', '2025-09-21 17:25:00+0000', 000000c4-0000-1000-8000-0000000000c4, 'S014', 'Station Vénissieux', 'return', 'bike');
APPLY BATCH;

-- Event 197
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S015', '2025-09-21', '2025-09-21 17:50:00+0000', 000000c5-0000-1000-8000-0000000000c5, 'user_009', 'rent', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_009', '2025-09', '2025-09-21 17:50:00+0000', 000000c5-0000-1000-8000-0000000000c5, 'S015', 'Station Bron', 'rent', 'bike');
APPLY BATCH;

-- Event 198
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S001', '2025-09-21', '2025-09-21 18:15:00+0000', 000000c6-0000-1000-8000-0000000000c6, 'user_010', 'return', 'scooter');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_010', '2025-09', '2025-09-21 18:15:00+0000', 000000c6-0000-1000-8000-0000000000c6, 'S001', 'Station République', 'return', 'scooter');
APPLY BATCH;

-- Event 199
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S002', '2025-09-21', '2025-09-21 18:40:00+0000', 000000c7-0000-1000-8000-0000000000c7, 'user_011', 'rent', 'car');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_011', '2025-09', '2025-09-21 18:40:00+0000', 000000c7-0000-1000-8000-0000000000c7, 'S002', 'Station Bellecour', 'rent', 'car');
APPLY BATCH;

-- Event 200
BEGIN BATCH
INSERT INTO station_passages (station_id, day, event_time, event_id, user_id, event_type, vehicle_type)
VALUES ('S003', '2025-09-21', '2025-09-21 19:05:00+0000', 000000c8-0000-1000-8000-0000000000c8, 'user_012', 'return', 'bike');

INSERT INTO user_connexions (user_id, month, event_time, event_id, station_id, station_name, event_type, vehicle_type)
VALUES ('user_012', '2025-09', '2025-09-21 19:05:00+0000', 000000c8-0000-1000-8000-0000000000c8, 'S003', 'Station Confluence', 'return', 'bike');
APPLY BATCH;


-- ============================================================
-- Compteurs pré-agrégés pour US-C4
-- ============================================================

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S001' AND day = '2025-09-15';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S001' AND day = '2025-09-16';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S001' AND day = '2025-09-17';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S001' AND day = '2025-09-18';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S001' AND day = '2025-09-19';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S001' AND day = '2025-09-20';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S001' AND day = '2025-09-21';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S002' AND day = '2025-09-15';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S002' AND day = '2025-09-16';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S002' AND day = '2025-09-17';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S002' AND day = '2025-09-18';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S002' AND day = '2025-09-19';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S002' AND day = '2025-09-20';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S002' AND day = '2025-09-21';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S003' AND day = '2025-09-15';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S003' AND day = '2025-09-16';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S003' AND day = '2025-09-17';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S003' AND day = '2025-09-18';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S003' AND day = '2025-09-19';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S003' AND day = '2025-09-20';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S003' AND day = '2025-09-21';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S004' AND day = '2025-09-15';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S004' AND day = '2025-09-16';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S004' AND day = '2025-09-17';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S004' AND day = '2025-09-18';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S004' AND day = '2025-09-19';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S004' AND day = '2025-09-20';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S004' AND day = '2025-09-21';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S005' AND day = '2025-09-15';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S005' AND day = '2025-09-16';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S005' AND day = '2025-09-17';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S005' AND day = '2025-09-18';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S005' AND day = '2025-09-19';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S005' AND day = '2025-09-20';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S005' AND day = '2025-09-21';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S006' AND day = '2025-09-15';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S006' AND day = '2025-09-16';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S006' AND day = '2025-09-17';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S006' AND day = '2025-09-18';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S006' AND day = '2025-09-19';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S006' AND day = '2025-09-20';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S006' AND day = '2025-09-21';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S007' AND day = '2025-09-15';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S007' AND day = '2025-09-16';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S007' AND day = '2025-09-17';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S007' AND day = '2025-09-18';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S007' AND day = '2025-09-19';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S007' AND day = '2025-09-20';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S007' AND day = '2025-09-21';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S008' AND day = '2025-09-15';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S008' AND day = '2025-09-16';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S008' AND day = '2025-09-17';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S008' AND day = '2025-09-18';

UPDATE daily_station_stats
SET total_events = total_events + 1,
    total_rents = total_rents + 1,
    total_returns = total_returns + 0
WHERE station_id = 'S008' AND day = '2025-09-19';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S008' AND day = '2025-09-20';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S008' AND day = '2025-09-21';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S009' AND day = '2025-09-15';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S009' AND day = '2025-09-16';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S009' AND day = '2025-09-17';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S009' AND day = '2025-09-18';

UPDATE daily_station_stats
SET total_events = total_events + 1,
    total_rents = total_rents + 0,
    total_returns = total_returns + 1
WHERE station_id = 'S009' AND day = '2025-09-19';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S009' AND day = '2025-09-20';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S009' AND day = '2025-09-21';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S010' AND day = '2025-09-15';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S010' AND day = '2025-09-16';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S010' AND day = '2025-09-17';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S010' AND day = '2025-09-18';

UPDATE daily_station_stats
SET total_events = total_events + 1,
    total_rents = total_rents + 1,
    total_returns = total_returns + 0
WHERE station_id = 'S010' AND day = '2025-09-19';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S010' AND day = '2025-09-20';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S010' AND day = '2025-09-21';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S011' AND day = '2025-09-15';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S011' AND day = '2025-09-16';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S011' AND day = '2025-09-17';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S011' AND day = '2025-09-18';

UPDATE daily_station_stats
SET total_events = total_events + 1,
    total_rents = total_rents + 0,
    total_returns = total_returns + 1
WHERE station_id = 'S011' AND day = '2025-09-19';

UPDATE daily_station_stats
SET total_events = total_events + 1,
    total_rents = total_rents + 0,
    total_returns = total_returns + 1
WHERE station_id = 'S011' AND day = '2025-09-20';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S011' AND day = '2025-09-21';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S012' AND day = '2025-09-15';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S012' AND day = '2025-09-16';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S012' AND day = '2025-09-17';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S012' AND day = '2025-09-18';

UPDATE daily_station_stats
SET total_events = total_events + 1,
    total_rents = total_rents + 1,
    total_returns = total_returns + 0
WHERE station_id = 'S012' AND day = '2025-09-19';

UPDATE daily_station_stats
SET total_events = total_events + 1,
    total_rents = total_rents + 1,
    total_returns = total_returns + 0
WHERE station_id = 'S012' AND day = '2025-09-20';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S012' AND day = '2025-09-21';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S013' AND day = '2025-09-15';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S013' AND day = '2025-09-16';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S013' AND day = '2025-09-17';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S013' AND day = '2025-09-18';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S013' AND day = '2025-09-19';

UPDATE daily_station_stats
SET total_events = total_events + 1,
    total_rents = total_rents + 0,
    total_returns = total_returns + 1
WHERE station_id = 'S013' AND day = '2025-09-20';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S013' AND day = '2025-09-21';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S014' AND day = '2025-09-15';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S014' AND day = '2025-09-16';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S014' AND day = '2025-09-17';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S014' AND day = '2025-09-18';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S014' AND day = '2025-09-19';

UPDATE daily_station_stats
SET total_events = total_events + 1,
    total_rents = total_rents + 1,
    total_returns = total_returns + 0
WHERE station_id = 'S014' AND day = '2025-09-20';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S014' AND day = '2025-09-21';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S015' AND day = '2025-09-15';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S015' AND day = '2025-09-16';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S015' AND day = '2025-09-17';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S015' AND day = '2025-09-18';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S015' AND day = '2025-09-19';

UPDATE daily_station_stats
SET total_events = total_events + 1,
    total_rents = total_rents + 0,
    total_returns = total_returns + 1
WHERE station_id = 'S015' AND day = '2025-09-20';

UPDATE daily_station_stats
SET total_events = total_events + 2,
    total_rents = total_rents + 1,
    total_returns = total_returns + 1
WHERE station_id = 'S015' AND day = '2025-09-21';

-- ============================================================
-- Vérifications rapides
-- ============================================================
SELECT COUNT(*) FROM station_passages;
SELECT COUNT(*) FROM user_connexions;
SELECT * FROM daily_station_stats WHERE station_id = 'S001';
