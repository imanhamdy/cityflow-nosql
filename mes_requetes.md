# Mes requêtes MongoDB

## 1. Trouvez tous les utilisateurs entre 25 et 35 ans (inclus aux deux bornes)

### Query

```json
{
  "age": {
    "$gte": 25,
    "$lte": 35
  }
}
```

---

## 2. Trouvez les utilisateurs dont l'email contient example.com

### Query

```json
{
  "email": {
    "$regex": "example.com"
  }
}
```

---

## 3. Trouvez les utilisateurs qui ont exactement 2 adresses

### Query

```json
{
  "addresses": {
    "$size": 2
  }
}
```

---

## 4. Trouvez les utilisateurs qui n'ont pas le champ preferences

### Query

```json
{
  "preferences": {
    "$exists": false
  }
}
```

---

## 5. Trouvez les utilisateurs habitant Lyon OU Villeurbanne, et de plus de 25 ans

### Query

```json
{
  "$and": [
    {
      "$or": [
        {
          "addresses.city": "Lyon"
        },
        {
          "addresses.city": "Villeurbanne"
        }
      ]
    },
    {
      "age": {
        "$gt": 25
      }
    }
  ]
}
```

---

## 6. Trouvez les utilisateurs qui ont au moins une adresse de type home à Lyon

### Query

```json
{
  "addresses": {
    "$elemMatch": {
      "type": "home",
      "city": "Lyon"
    }
  }
}
```

---

## 7. Trouvez les utilisateurs qui ont les tags premium ET eco-friendly ensemble

### Query

```json
{
  "tags": {
    "$all": [
      "premium",
      "eco-friendly"
    ]
  }
}
```

---

## 8. Affichez les 3 utilisateurs les plus âgés

### Query

```json
{}
```

### Projection

```json
{
  "firstName": 1,
  "age": 1,
  "email": 1,
  "_id": 0
}
```

### Sort

```json
{
  "age": -1
}
```

### Limit

```txt
3
```

---

## 9. Affichez les utilisateurs triés par ville (alphabétique), puis par âge décroissant

### Query

```json
{}
```

### Sort

```json
{
  "addresses.city": 1,
  "age": -1
}
```

---

## 10. Pagination : page 2 avec 2 utilisateurs par page, triés par createdAt

### Query

```json
{}
```

### Sort

```json
{
  "createdAt": 1
}
```

### Limit

```txt
2
```

### Skip

```txt
2
```

---

## 11. Trouvez les utilisateurs vérifiés âgés de moins de 30 ans, n'habitant pas Lyon

### Query

```json
{
  "isVerified": true,
  "age": {
    "$lt": 30
  },
  "addresses.city": {
    "$ne": "Lyon"
  }
}
```

---

## 12. Trouvez les utilisateurs dont au moins un tag commence par la lettre 'p'

### Query

```json
{
  "tags": {
    "$regex": "^p"
  }
}
```

---

# Rappel des opérateurs utilisés

| Opérateur | Signification |
|------------|---------------|
| `$gte` | supérieur ou égal |
| `$lte` | inférieur ou égal |
| `$gt` | strictement supérieur |
| `$lt` | strictement inférieur |
| `$regex` | recherche par motif texte |
| `$size` | taille exacte d'un tableau |
| `$exists` | vérifie l'existence d'un champ |
| `$and` | ET logique |
| `$or` | OU logique |
| `$elemMatch` | recherche dans un tableau d'objets |
| `$all` | contient toutes les valeurs demandées |
| `$ne` | différent de |

# Notes

- Query = filtre les documents
- Projection = choisit les champs affichés
- Sort = trie les résultats
- Limit = limite le nombre de résultats
- Skip = ignore un nombre de résultats (pagination)
