// CityFlow - MongoDB seed data
// Runs automatically on first `docker compose up` via /docker-entrypoint-initdb.d/

db = db.getSiblingDB('cityflow');

db.vehicles.drop();
db.users.drop();
db.trips.drop();

// ─── VEHICLES (20 documents) ──────────────────────────────────────────────────

db.vehicles.insertMany([
  { vehicleId:"v001", type:"vélo",    brand:"Pony",     model:"City e-Bike",   status:"available",    district:"1er arrondissement", station:"Bellecour",      batteryLevel:92, lastMaintenance: new Date("2025-04-10") },
  { vehicleId:"v002", type:"vélo",    brand:"Pony",     model:"City e-Bike",   status:"in_use",       district:"1er arrondissement", station:"Bellecour",      batteryLevel:45, lastMaintenance: new Date("2025-03-22") },
  { vehicleId:"v003", type:"vélo",    brand:"Nextbike", model:"Urban",         status:"available",    district:"3ème arrondissement", station:"Part-Dieu",      batteryLevel:78, lastMaintenance: new Date("2025-05-01") },
  { vehicleId:"v004", type:"vélo",    brand:"Nextbike", model:"Urban",         status:"maintenance",  district:"3ème arrondissement", station:"Garibaldi",      batteryLevel:12, lastMaintenance: new Date("2025-02-14") },
  { vehicleId:"v005", type:"vélo",    brand:"Pony",     model:"City e-Bike",   status:"available",    district:"6ème arrondissement", station:"Brotteaux",      batteryLevel:88, lastMaintenance: new Date("2025-05-18") },
  { vehicleId:"v006", type:"vélo",    brand:"Pony",     model:"City e-Bike",   status:"available",    district:"7ème arrondissement", station:"Jean Macé",      batteryLevel:67, lastMaintenance: new Date("2025-04-30") },
  { vehicleId:"v007", type:"vélo",    brand:"Nextbike", model:"Urban",         status:"in_use",       district:"4ème arrondissement", station:"Croix-Rousse",   batteryLevel:55, lastMaintenance: new Date("2025-03-10") },

  { vehicleId:"v008", type:"scooter", brand:"Dott",     model:"Gen 3",         status:"available",    district:"2ème arrondissement", station:"Confluence",     batteryLevel:95, lastMaintenance: new Date("2025-05-20") },
  { vehicleId:"v009", type:"scooter", brand:"Dott",     model:"Gen 3",         status:"available",    district:"3ème arrondissement", station:"Saxe-Gambetta",  batteryLevel:81, lastMaintenance: new Date("2025-05-15") },
  { vehicleId:"v010", type:"scooter", brand:"Lime",     model:"S3",            status:"in_use",       district:"1er arrondissement", station:"Vieux-Lyon",     batteryLevel:60, lastMaintenance: new Date("2025-04-02") },
  { vehicleId:"v011", type:"scooter", brand:"Lime",     model:"S3",            status:"available",    district:"6ème arrondissement", station:"Foch",           batteryLevel:73, lastMaintenance: new Date("2025-05-08") },
  { vehicleId:"v012", type:"scooter", brand:"Dott",     model:"Gen 3",         status:"maintenance",  district:"9ème arrondissement", station:"Vaise",          batteryLevel:20, lastMaintenance: new Date("2025-01-30") },
  { vehicleId:"v013", type:"scooter", brand:"Lime",     model:"S3",            status:"available",    district:"7ème arrondissement", station:"Gerland",        batteryLevel:90, lastMaintenance: new Date("2025-05-22") },

  { vehicleId:"v014", type:"voiture", brand:"Renault",  model:"Zoé",           status:"available",    district:"2ème arrondissement", station:"Perrache",       batteryLevel:100, lastMaintenance: new Date("2025-05-05") },
  { vehicleId:"v015", type:"voiture", brand:"Citroën",  model:"ë-C3",          status:"available",    district:"3ème arrondissement", station:"Part-Dieu",      batteryLevel:88,  lastMaintenance: new Date("2025-04-25") },
  { vehicleId:"v016", type:"voiture", brand:"Peugeot",  model:"e-208",         status:"in_use",       district:"8ème arrondissement", station:"Mermoz",         batteryLevel:55,  lastMaintenance: new Date("2025-03-18") },
  { vehicleId:"v017", type:"voiture", brand:"Renault",  model:"Zoé",           status:"available",    district:"9ème arrondissement", station:"Gorge de Loup",  batteryLevel:72,  lastMaintenance: new Date("2025-05-12") },
  { vehicleId:"v018", type:"voiture", brand:"Tesla",    model:"Model 3",       status:"available",    district:"6ème arrondissement", station:"Brotteaux",      batteryLevel:95,  lastMaintenance: new Date("2025-05-25") },
  { vehicleId:"v019", type:"voiture", brand:"Citroën",  model:"ë-C3",          status:"available",    district:"4ème arrondissement", station:"Croix-Rousse",   batteryLevel:83,  lastMaintenance: new Date("2025-04-20") },
  { vehicleId:"v020", type:"voiture", brand:"Peugeot",  model:"e-208",         status:"maintenance",  district:"5ème arrondissement", station:"Saint-Paul",     batteryLevel:30,  lastMaintenance: new Date("2025-02-28") }
]);

// ─── USERS (20 documents) ─────────────────────────────────────────────────────

db.users.insertMany([
  { userId:"u001", firstName:"Alice",   lastName:"Martin",    email:"alice.martin@cityflow.fr",   phone:"+33612345678", role:"passenger", isVerified:true,  createdAt: new Date("2024-01-15"), preferences:{ transport:["vélo","metro"], notifications:true } },
  { userId:"u002", firstName:"Karim",   lastName:"Bouaziz",   email:"karim.bouaziz@cityflow.fr",  phone:"+33623456789", role:"passenger", isVerified:true,  createdAt: new Date("2024-02-03"), preferences:{ transport:["metro","bus"],  notifications:false } },
  { userId:"u003", firstName:"Sophie",  lastName:"Leclerc",   email:"sophie.leclerc@cityflow.fr", phone:"+33634567890", role:"driver",    isVerified:true,  createdAt: new Date("2024-01-20"), preferences:{ transport:["voiture"],     notifications:true } },
  { userId:"u004", firstName:"Marc",    lastName:"Dupont",    email:"marc.dupont@cityflow.fr",    phone:"+33645678901", role:"driver",    isVerified:true,  createdAt: new Date("2024-03-10"), preferences:{ transport:["voiture"],     notifications:true } },
  { userId:"u005", firstName:"Emma",    lastName:"Rousseau",  email:"emma.rousseau@cityflow.fr",  phone:"+33656789012", role:"passenger", isVerified:false, createdAt: new Date("2024-04-05"), preferences:{ transport:["vélo","tram"], notifications:true } },
  { userId:"u006", firstName:"Thomas",  lastName:"Bernard",   email:"thomas.bernard@cityflow.fr", phone:"+33667890123", role:"driver",    isVerified:true,  createdAt: new Date("2024-02-18"), preferences:{ transport:["voiture"],     notifications:false } },
  { userId:"u007", firstName:"Julie",   lastName:"Moreau",    email:"julie.moreau@cityflow.fr",   phone:"+33678901234", role:"passenger", isVerified:true,  createdAt: new Date("2024-05-22"), preferences:{ transport:["metro","vélo"], notifications:true } },
  { userId:"u008", firstName:"Nicolas", lastName:"Petit",     email:"nicolas.petit@cityflow.fr",  phone:"+33689012345", role:"driver",    isVerified:true,  createdAt: new Date("2024-01-08"), preferences:{ transport:["voiture"],     notifications:true } },
  { userId:"u009", firstName:"Léa",     lastName:"Girard",    email:"lea.girard@cityflow.fr",     phone:"+33690123456", role:"passenger", isVerified:false, createdAt: new Date("2024-06-01"), preferences:{ transport:["scooter"],     notifications:false } },
  { userId:"u010", firstName:"Antoine", lastName:"Mercier",   email:"antoine.mercier@cityflow.fr",phone:"+33601234567", role:"passenger", isVerified:true,  createdAt: new Date("2024-03-30"), preferences:{ transport:["bus","metro"],  notifications:true } },
  { userId:"u011", firstName:"Camille", lastName:"Blanc",     email:"camille.blanc@cityflow.fr",  phone:"+33611234568", role:"driver",    isVerified:true,  createdAt: new Date("2024-02-25"), preferences:{ transport:["voiture"],     notifications:true } },
  { userId:"u012", firstName:"Hugo",    lastName:"Fontaine",  email:"hugo.fontaine@cityflow.fr",  phone:"+33622345679", role:"passenger", isVerified:true,  createdAt: new Date("2024-04-14"), preferences:{ transport:["vélo"],        notifications:true } },
  { userId:"u013", firstName:"Manon",   lastName:"Garnier",   email:"manon.garnier@cityflow.fr",  phone:"+33633456790", role:"passenger", isVerified:false, createdAt: new Date("2024-07-09"), preferences:{ transport:["metro"],       notifications:false } },
  { userId:"u014", firstName:"Lucas",   lastName:"Perrin",    email:"lucas.perrin@cityflow.fr",   phone:"+33644567801", role:"passenger", isVerified:true,  createdAt: new Date("2024-05-11"), preferences:{ transport:["scooter","vélo"], notifications:true } },
  { userId:"u015", firstName:"Clara",   lastName:"Simon",     email:"clara.simon@cityflow.fr",    phone:"+33655678902", role:"passenger", isVerified:true,  createdAt: new Date("2024-08-03"), preferences:{ transport:["tram","bus"],  notifications:true } },
  { userId:"u016", firstName:"Romain",  lastName:"Lefebvre",  email:"romain.lefebvre@cityflow.fr",phone:"+33666789013", role:"driver",    isVerified:true,  createdAt: new Date("2024-01-30"), preferences:{ transport:["voiture"],     notifications:true } },
  { userId:"u017", firstName:"Inès",    lastName:"Morel",     email:"ines.morel@cityflow.fr",     phone:"+33677890124", role:"passenger", isVerified:true,  createdAt: new Date("2024-09-17"), preferences:{ transport:["vélo","metro"], notifications:false } },
  { userId:"u018", firstName:"Axel",    lastName:"Barbier",   email:"axel.barbier@cityflow.fr",   phone:"+33688901235", role:"passenger", isVerified:false, createdAt: new Date("2024-06-28"), preferences:{ transport:["scooter"],     notifications:true } },
  { userId:"u019", firstName:"Pauline", lastName:"Noel",      email:"pauline.noel@cityflow.fr",   phone:"+33699012346", role:"passenger", isVerified:true,  createdAt: new Date("2024-10-05"), preferences:{ transport:["metro"],       notifications:true } },
  { userId:"u020", firstName:"Théo",    lastName:"Renard",    email:"theo.renard@cityflow.fr",    phone:"+33600123457", role:"passenger", isVerified:true,  createdAt: new Date("2024-11-12"), preferences:{ transport:["vélo"],        notifications:false } }
]);

// ─── TRIPS (25 documents) ─────────────────────────────────────────────────────
// Steps are embedded (rich nested structure, always queried with the trip).
// userId / driverId reference users by vehicleId; no $lookup needed for typical reads.

db.trips.insertMany([
  {
    tripId:"t001", userId:"u001", vehicleId:"v001",
    date: new Date("2025-01-08"), distance:4.2, duration:22, status:"completed",
    steps:[
      { mode:"vélo",  from:"Bellecour",   to:"Perrache",  duration:8 },
      { mode:"metro", from:"Perrache",    to:"Part-Dieu", duration:14 }
    ],
    comment:"Trajet très rapide, le vélo était bien chargé. Je recommande Bellecour.", rating:4.5
  },
  {
    tripId:"t002", userId:"u002", driverId:"u003", vehicleId:"v014",
    date: new Date("2025-01-08"), distance:7.8, duration:35, status:"completed",
    steps:[
      { mode:"covoiturage", from:"Perrache",  to:"Brotteaux", duration:35 }
    ],
    comment:"Conductrice ponctuelle et véhicule propre. Très confortable.", rating:5.0
  },
  {
    tripId:"t003", userId:"u005", vehicleId:"v008",
    date: new Date("2025-01-09"), distance:2.1, duration:12, status:"completed",
    steps:[
      { mode:"scooter", from:"Confluence", to:"Bellecour", duration:12 }
    ],
    comment:"Scooter en bon état, trajet pratique pour éviter le métro bondé.", rating:4.0
  },
  {
    tripId:"t004", userId:"u007", driverId:"u004", vehicleId:"v015",
    date: new Date("2025-01-10"), distance:9.3, duration:28, status:"completed",
    steps:[
      { mode:"covoiturage", from:"Part-Dieu", to:"Gerland", duration:28 }
    ],
    comment:"Bon conducteur, musique agréable, pas de retard.", rating:4.8
  },
  {
    tripId:"t005", userId:"u009", vehicleId:"v009",
    date: new Date("2025-01-12"), distance:3.4, duration:18, status:"completed",
    steps:[
      { mode:"scooter", from:"Saxe-Gambetta", to:"Jean Macé", duration:18 }
    ],
    comment:"Scooter rapide mais route encombrée en début de trajet.", rating:3.5
  },
  {
    tripId:"t006", userId:"u012", vehicleId:"v003",
    date: new Date("2025-01-15"), distance:5.6, duration:30, status:"completed",
    steps:[
      { mode:"vélo",  from:"Part-Dieu",   to:"Croix-Rousse", duration:18 },
      { mode:"metro", from:"Croix-Rousse", to:"Vaise",       duration:12 }
    ],
    comment:"Belle balade à vélo dans la montée de la Croix-Rousse. Recommande le vélo.", rating:4.2
  },
  {
    tripId:"t007", userId:"u001", driverId:"u006", vehicleId:"v016",
    date: new Date("2025-01-20"), distance:12.1, duration:40, status:"completed",
    steps:[
      { mode:"covoiturage", from:"Bellecour", to:"Mermoz", duration:40 }
    ],
    comment:"Conducteur rapide, trajet fluide sur le périphérique.", rating:4.6
  },
  {
    tripId:"t008", userId:"u014", vehicleId:"v006",
    date: new Date("2025-01-22"), distance:2.8, duration:15, status:"completed",
    steps:[
      { mode:"vélo", from:"Jean Macé", to:"Gerland", duration:15 }
    ],
    comment:"Super piste cyclable entre Jean Macé et Gerland, je recommande le vélo ici.", rating:5.0
  },
  {
    tripId:"t009", userId:"u010", driverId:"u008", vehicleId:"v017",
    date: new Date("2025-02-03"), distance:8.5, duration:32, status:"completed",
    steps:[
      { mode:"covoiturage", from:"Gorge de Loup", to:"Part-Dieu", duration:32 }
    ],
    comment:"Très bon conducteur, voiture propre et confortable.", rating:4.9
  },
  {
    tripId:"t010", userId:"u017", vehicleId:"v005",
    date: new Date("2025-02-03"), distance:3.1, duration:16, status:"completed",
    steps:[
      { mode:"vélo",  from:"Brotteaux",  to:"Foch",       duration:8 },
      { mode:"tram",  from:"Foch",       to:"Bellecour",  duration:8 }
    ],
    comment:"Combinaison vélo et tramway idéale, pas de correspondance difficile.", rating:4.3
  },
  {
    tripId:"t011", userId:"u013", vehicleId:"v011",
    date: new Date("2025-02-10"), distance:1.8, duration:10, status:"completed",
    steps:[
      { mode:"scooter", from:"Foch", to:"Brotteaux", duration:10 }
    ],
    comment:"Court trajet, scooter disponible immédiatement. Pratique.", rating:4.1
  },
  {
    tripId:"t012", userId:"u002", driverId:"u011", vehicleId:"v019",
    date: new Date("2025-02-14"), distance:6.7, duration:25, status:"completed",
    steps:[
      { mode:"covoiturage", from:"Croix-Rousse", to:"Part-Dieu", duration:25 }
    ],
    comment:"Conductrice Camille très sympathique et ponctuelle.", rating:5.0
  },
  {
    tripId:"t013", userId:"u015", vehicleId:"v009",
    date: new Date("2025-02-18"), distance:2.4, duration:13, status:"completed",
    steps:[
      { mode:"scooter", from:"Saxe-Gambetta", to:"Garibaldi", duration:13 }
    ],
    comment:"Trajet rapide mais la batterie était basse à l'arrivée. À améliorer.", rating:3.0
  },
  {
    tripId:"t014", userId:"u020", vehicleId:"v003",
    date: new Date("2025-03-05"), distance:4.9, duration:26, status:"completed",
    steps:[
      { mode:"vélo",  from:"Part-Dieu",  to:"Bellecour",  duration:15 },
      { mode:"metro", from:"Bellecour",  to:"Vieux-Lyon", duration:11 }
    ],
    comment:"Vélo en parfait état, trajet agréable. Je recommande cette combinaison vélo-métro.", rating:4.7
  },
  {
    tripId:"t015", userId:"u007", driverId:"u016", vehicleId:"v014",
    date: new Date("2025-03-05"), distance:11.2, duration:38, status:"completed",
    steps:[
      { mode:"covoiturage", from:"Perrache", to:"Vaise", duration:38 }
    ],
    comment:"Conducteur Romain professionnel. Recommande pour les longs trajets en covoiturage.", rating:4.8
  },
  {
    tripId:"t016", userId:"u001", vehicleId:"v007",
    date: new Date("2025-03-12"), distance:3.7, duration:20, status:"completed",
    steps:[
      { mode:"vélo", from:"Croix-Rousse", to:"Brotteaux", duration:20 }
    ],
    comment:"Descente agréable depuis la Croix-Rousse. Vélo parfaitement entretenu.", rating:4.4
  },
  {
    tripId:"t017", userId:"u019", driverId:"u003", vehicleId:"v015",
    date: new Date("2025-03-20"), distance:7.3, duration:29, status:"completed",
    steps:[
      { mode:"covoiturage", from:"Part-Dieu", to:"Confluence", duration:29 }
    ],
    comment:"Sophie arrive toujours à l'heure. Voiture confortable.", rating:5.0
  },
  {
    tripId:"t018", userId:"u012", vehicleId:"v005",
    date: new Date("2025-04-02"), distance:2.2, duration:11, status:"completed",
    steps:[
      { mode:"vélo", from:"Brotteaux", to:"Saxe-Gambetta", duration:11 }
    ],
    comment:"Vélo électrique très pratique, aucun effort dans les côtes.", rating:4.9
  },
  {
    tripId:"t019", userId:"u018", driverId:"u008", vehicleId:"v017",
    date: new Date("2025-04-02"), distance:9.8, duration:36, status:"completed",
    steps:[
      { mode:"covoiturage", from:"Gorge de Loup", to:"Gerland", duration:36 }
    ],
    comment:"Nicolas est un excellent conducteur, trajet sans retard.", rating:5.0
  },
  {
    tripId:"t020", userId:"u004", vehicleId:"v018",
    date: new Date("2025-04-10"), distance:5.0, duration:22, status:"completed",
    steps:[
      { mode:"voiture", from:"Brotteaux", to:"Jean Macé", duration:22 }
    ],
    comment:"Trajet solo en Tesla, silencieux et rapide.", rating:4.6
  },
  {
    tripId:"t021", userId:"u011", driverId:"u004", vehicleId:"v018",
    date: new Date("2025-04-15"), distance:6.4, duration:24, status:"completed",
    steps:[
      { mode:"covoiturage", from:"Brotteaux", to:"Part-Dieu", duration:24 }
    ],
    comment:"Marc conduit bien mais a eu du retard au départ.", rating:3.8
  },
  {
    tripId:"t022", userId:"u006", vehicleId:"v013",
    date: new Date("2025-05-05"), distance:3.9, duration:21, status:"completed",
    steps:[
      { mode:"scooter", from:"Gerland", to:"Jean Macé",  duration:12 },
      { mode:"metro",   from:"Jean Macé", to:"Bellecour", duration:9 }
    ],
    comment:"Scooter rapide, puis métro direct. Combinaison très pratique.", rating:4.5
  },
  {
    tripId:"t023", userId:"u001", driverId:"u016", vehicleId:"v014",
    date: new Date("2025-05-12"), distance:8.0, duration:30, status:"completed",
    steps:[
      { mode:"covoiturage", from:"Perrache", to:"Mermoz", duration:30 }
    ],
    comment:"Romain conduit prudemment, très agréable.", rating:4.7
  },
  {
    tripId:"t024", userId:"u014", vehicleId:"v001",
    date: new Date("2025-05-20"), distance:3.3, duration:17, status:"completed",
    steps:[
      { mode:"vélo", from:"Bellecour", to:"Garibaldi", duration:17 }
    ],
    comment:"Parfait pour une promenade matinale, vélo bien disponible à Bellecour.", rating:4.8
  },
  {
    tripId:"t025", userId:"u003", driverId:"u011", vehicleId:"v019",
    date: new Date("2025-05-28"), distance:7.1, duration:28, status:"completed",
    steps:[
      { mode:"covoiturage", from:"Croix-Rousse", to:"Confluence", duration:28 }
    ],
    comment:"Camille est toujours ponctuelle et souriante. Trajet confortable.", rating:5.0
  },
  {
    tripId:"t026", userId:"u005", driverId:"u003", vehicleId:"v015",
    date: new Date("2025-05-30"), distance:6.5, duration:26, status:"completed",
    steps:[
      { mode:"covoiturage", from:"Confluence", to:"Part-Dieu", duration:26 }
    ],
    comment:"Sophie est une conductrice exemplaire, je recommande vivement.", rating:4.8
  },
  {
    tripId:"t027", userId:"u015", driverId:"u008", vehicleId:"v017",
    date: new Date("2025-06-02"), distance:5.2, duration:22, status:"completed",
    steps:[
      { mode:"covoiturage", from:"Part-Dieu", to:"Brotteaux", duration:22 }
    ],
    comment:"Nicolas très ponctuel et sympa, voiture propre.", rating:4.7
  },
  {
    tripId:"t028", userId:"u001", vehicleId:"v003",
    date: new Date("2025-06-05"), distance:2.9, duration:14, status:"completed",
    steps:[
      { mode:"vélo", from:"Garibaldi", to:"Bellecour", duration:14 }
    ],
    comment:"Courte balade en vélo, parfait pour les petits trajets quotidiens.", rating:4.6
  },
  {
    tripId:"t029", userId:"u014", driverId:"u003", vehicleId:"v014",
    date: new Date("2025-06-08"), distance:8.8, duration:33, status:"completed",
    steps:[
      { mode:"covoiturage", from:"Perrache", to:"Vénissieux", duration:33 }
    ],
    comment:"Sophie arrive toujours à l'heure, trajet très agréable vers Vénissieux.", rating:5.0
  },
  {
    tripId:"t030", userId:"u002", driverId:"u016", vehicleId:"v018",
    date: new Date("2025-06-10"), distance:7.6, duration:29, status:"completed",
    steps:[
      { mode:"covoiturage", from:"Gorge de Loup", to:"Bellecour", duration:29 }
    ],
    comment:"Romain conduit prudemment et connaît bien les routes lyonnaises.", rating:4.9
  }
]);

// ─── INDEXES ──────────────────────────────────────────────────────────────────

// US-M1 - last trips per user
db.trips.createIndex({ userId: 1, date: -1 });

// US-M2 - vehicles by type + district
db.vehicles.createIndex({ type: 1, district: 1, status: 1 });

// US-M3 - aggregation on date and driverId
db.trips.createIndex({ date: 1 });
db.trips.createIndex({ driverId: 1 });

// US-M4 - full-text search on comments
db.trips.createIndex({ comment: "text" });

// User lookup
db.users.createIndex({ userId: 1 }, { unique: true });
db.vehicles.createIndex({ vehicleId: 1 }, { unique: true });

print("✓ CityFlow MongoDB seed complete - users:20, vehicles:20, trips:30");
