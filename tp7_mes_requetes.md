# TP7 - Requêtes pratiques MongoDB

## Objectif

Dans ce TP, l'objectif est d'écrire des requêtes MongoDB sur la collection `users` en utilisant le mode **Advanced** de mongo-express.

Chaque requête est composée de plusieurs parties possibles :

- `Query` : le filtre, équivalent du `WHERE`
- `Projection` : les champs à afficher
- `Sort` : le tri
- `Limit` : le nombre maximum de résultats
- `Skip` : le nombre de résultats à ignorer pour la pagination

Les requêtes doivent être écrites en JSON strict dans mongo-express.

---

# Niveau 1 - Filtres simples

## 1. Trouver tous les utilisateurs entre 25 et 35 ans inclus

### Query

```json
{
  "age": {
    "$gte": 25,
    "$lte": 35
  }
}
```

### Réponse obtenue

Utilisateurs retournés :

- Alice Martin, 28 ans, `alice@example.com`
- Sarah Chevalier, 30 ans, `sarah@example.com`
- Camille Morel, 34 ans, `camille@example.com`

### Explication

Cette requête filtre les utilisateurs selon leur âge.

- `$gte` signifie **greater than or equal**, donc supérieur ou égal.
- `$lte` signifie **less than or equal**, donc inférieur ou égal.

La requête retourne donc les utilisateurs dont l'âge est compris entre 25 et 35 ans, bornes incluses.

---

## 2. Trouver les utilisateurs dont l'email contient `example.com`

### Query

```json
{
  "email": {
    "$regex": "example.com"
  }
}
```

### Réponse obtenue

Utilisateurs retournés :

- Alice Martin, `alice@example.com`
- Laura Dubois, `laura@example.com`
- Sarah Chevalier, `sarah@example.com`
- Camille Morel, `camille@example.com`

### Explication

Cette requête utilise l'opérateur `$regex`.

`$regex` permet de faire une recherche textuelle dans une chaîne de caractères.  
Ici, MongoDB retourne tous les utilisateurs dont le champ `email` contient `example.com`.

---

## 3. Trouver les utilisateurs qui ont exactement 2 adresses

### Query

```json
{
  "addresses": {
    "$size": 2
  }
}
```

### Réponse obtenue

Utilisateurs retournés :

- Alice Martin
- Nicolas Faure
- Camille Morel

### Explication

Le champ `addresses` est un tableau.  
L'opérateur `$size` permet de vérifier la taille exacte d'un tableau.

Ici, MongoDB retourne uniquement les documents où le tableau `addresses` contient exactement 2 éléments.

---

## 4. Trouver les utilisateurs qui n'ont pas le champ `preferences`

### Query

```json
{
  "preferences": {
    "$exists": false
  }
}
```

### Réponse obtenue

Utilisateurs retournés :

- Nicolas Faure
- Yanis Leroy

### Explication

L'opérateur `$exists` permet de vérifier si un champ existe dans un document.

- `$exists: true` cherche les documents où le champ existe.
- `$exists: false` cherche les documents où le champ n'existe pas.

Ici, la requête retourne les utilisateurs qui n'ont pas de champ `preferences`.

---

# Niveau 2 - Combinaisons

## 5. Trouver les utilisateurs habitant Lyon OU Villeurbanne, et de plus de 25 ans

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

### Réponse obtenue

Utilisateurs retournés :

- Alice Martin, 28 ans
- Nicolas Faure, 37 ans
- Camille Morel, 34 ans

### Explication

Cette requête combine plusieurs conditions.

La partie `$or` signifie que l'utilisateur doit avoir une adresse à Lyon OU à Villeurbanne.

La partie `$and` impose que cette condition de ville soit vraie ET que l'utilisateur ait plus de 25 ans.

L'opérateur `$gt` signifie **strictement supérieur à**.

---

## 6. Trouver les utilisateurs qui ont au moins une adresse de type `home` à Lyon

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

### Réponse obtenue

Utilisateurs retournés :

- Alice Martin
- Laura Dubois
- Yanis Leroy

### Explication

Le champ `addresses` est un tableau d'objets.

L'opérateur `$elemMatch` permet de vérifier qu'un même élément du tableau respecte plusieurs conditions en même temps.

Ici, on cherche une adresse qui a :

- `type: "home"`
- `city: "Lyon"`

Sans `$elemMatch`, MongoDB pourrait trouver `type: home` dans une adresse et `city: Lyon` dans une autre adresse du même utilisateur.  
Avec `$elemMatch`, les deux conditions doivent être dans la même adresse.

---

## 7. Trouver les utilisateurs qui ont les tags `premium` ET `eco-friendly` ensemble

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

### Réponse obtenue

Utilisateurs retournés :

- Alice Martin
- Sarah Chevalier
- Camille Morel

### Explication

Le champ `tags` est un tableau.

L'opérateur `$all` permet de vérifier qu'un tableau contient toutes les valeurs demandées.

Ici, l'utilisateur doit avoir les deux tags :

- `premium`
- `eco-friendly`

Si l'utilisateur a seulement `premium` ou seulement `eco-friendly`, il n'est pas retourné.

---

# Niveau 3 - Tri et pagination

## 8. Afficher les 3 utilisateurs les plus âgés, avec seulement `firstName`, `age` et `email`

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

### Réponse obtenue

Utilisateurs retournés :

- Nicolas, 37 ans, `nicolas@gmail.com`
- Camille, 34 ans, `camille@example.com`
- Sarah, 30 ans, `sarah@example.com`

### Explication

La query `{}` signifie que l'on prend tous les utilisateurs.

La projection permet de choisir les champs affichés :

- `1` signifie afficher le champ.
- `0` signifie cacher le champ.

Ici, on affiche seulement :

- `firstName`
- `age`
- `email`

On cache `_id` avec `"_id": 0`.

Le tri `"age": -1` classe les utilisateurs du plus âgé au plus jeune.

`Limit: 3` permet de ne garder que les 3 premiers résultats.

---

## 9. Afficher les utilisateurs triés par ville alphabétique, puis par âge décroissant

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

### Réponse obtenue

Les utilisateurs sont affichés avec un tri sur la ville, puis sur l'âge.

Exemple de résultat observé :

- Alice Martin
- Laura Dubois
- Nicolas Faure
- Sarah Chevalier
- Yanis Leroy
- Camille Morel

### Explication

La query `{}` signifie que tous les utilisateurs sont sélectionnés.

Le tri fonctionne avec :

- `1` pour un tri croissant, donc alphabétique de A à Z.
- `-1` pour un tri décroissant.

Ici :

- `"addresses.city": 1` trie par ville en ordre alphabétique.
- `"age": -1` trie ensuite par âge décroissant.

Comme `addresses` est un tableau, le tri sur `addresses.city` peut dépendre des valeurs présentes dans les adresses de chaque utilisateur.

---

## 10. Pagination : page 2 avec 2 utilisateurs par page, triés par `createdAt`

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

### Réponse obtenue

MongoDB ignore les 2 premiers utilisateurs triés par `createdAt`, puis affiche les 2 suivants.

### Explication

Cette requête met en place une pagination.

Avec 2 utilisateurs par page :

- Page 1 : résultats 1 et 2
- Page 2 : résultats 3 et 4

La formule est :

```txt
skip = (page - 1) × limit
skip = (2 - 1) × 2
skip = 2
```

Donc on utilise :

- `Limit: 2`
- `Skip: 2`

Le tri par `createdAt` permet d'avoir un ordre stable entre les pages.

---

# Niveau 4 - Bonus

## 11. Trouver les utilisateurs vérifiés âgés de moins de 30 ans, n'habitant pas Lyon

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

### Réponse obtenue

Aucun résultat retourné avec les données actuelles.

### Explication

Cette requête cherche les utilisateurs qui respectent trois conditions :

- `isVerified` doit être égal à `true`
- `age` doit être inférieur à 30
- `addresses.city` doit être différent de `Lyon`

L'opérateur `$lt` signifie **inférieur à**.  
L'opérateur `$ne` signifie **not equal**, donc différent de.

Si aucun utilisateur ne correspond, ce n'est pas forcément une erreur. Cela signifie simplement que les données actuelles ne contiennent pas ce cas.

---

## 12. Trouver les utilisateurs dont au moins un tag commence par la lettre `p`

### Query

```json
{
  "tags": {
    "$regex": "^p"
  }
}
```

### Réponse obtenue

Utilisateurs retournés :

- Alice Martin
- Laura Dubois
- Sarah Chevalier
- Yanis Leroy
- Camille Morel

### Explication

Cette requête utilise `$regex` sur le tableau `tags`.

Le motif `^p` signifie : commence par la lettre `p`.

Cela permet de trouver les tags comme :

- `premium`
- `pro`
- `public`

MongoDB teste les valeurs du tableau et retourne les utilisateurs dont au moins un tag commence par `p`.

---

# Bilan du TP7

## Champs utilisés dans les filtres

Les principaux champs utilisés pour filtrer les documents sont :

- `age`
- `email`
- `addresses`
- `addresses.city`
- `addresses.type`
- `preferences`
- `tags`
- `isVerified`

## Champs utilisés dans les projections

Les champs affichés dans les projections sont :

- `firstName`
- `age`
- `email`
- `_id`

## Champs utilisés dans les tris

Les champs utilisés pour trier sont :

- `age`
- `addresses.city`
- `createdAt`

## Points importants à retenir

Les requêtes MongoDB dans mongo-express doivent être écrites en JSON strict :

```json
{
  "age": {
    "$gte": 25
  }
}
```

Il faut donc respecter :

- les guillemets doubles autour des noms de champs
- les guillemets doubles autour des chaînes de caractères
- les booléens sans guillemets : `true` ou `false`
- aucune virgule finale

---

# Rappel des opérateurs utilisés

| Opérateur | Signification |
|----------|---------------|
| `$gte` | supérieur ou égal |
| `$lte` | inférieur ou égal |
| `$gt` | strictement supérieur |
| `$lt` | strictement inférieur |
| `$regex` | recherche avec un motif texte |
| `$size` | taille exacte d'un tableau |
| `$exists` | vérifie si un champ existe |
| `$and` | ET logique |
| `$or` | OU logique |
| `$elemMatch` | cherche dans un tableau d'objets |
| `$all` | vérifie qu'un tableau contient toutes les valeurs demandées |
| `$ne` | différent de |

---

# Conclusion

Ce TP m'a permis de pratiquer les requêtes MongoDB dans mongo-express avec le mode Advanced.  
J'ai utilisé des filtres simples, des combinaisons avec `$and` et `$or`, des recherches dans des tableaux, des projections, des tris et de la pagination.