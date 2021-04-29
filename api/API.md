RSS App API Specification
=========================

Authentication
--------------

L'authentification fonctionne via le header `Authorization`.  

Une requête est authentifiée si la valeur du header `Authorization` de la requête est de la forme `Bearer TOKEN` où `TOKEN` est un token obtenu depuis le serveur suite à un login ou register.  

### Login classique

**Route:** `POST /auth/login`

**Corps de requête (MIME: `application/json`):**

```ts
{
    email: string,
    password: string,
}
```

**Réponse:** `200 OK`

**Corps de réponse (MIME: `application/json`):**

```ts
{
    token: string,
    expiry: string,
    user_id: string,
}
```

### Register classique

**Route:** `POST /auth/register`

**Corps de requête (MIME: `application/json`):**
```ts
{
    email: string,
    name: string,
    password: string,
}
```

**Réponse:** `200 OK`

**Corps de réponse (MIME: `application/json`):**

```ts
{
    token: string,
    expiry: string,
    user_id: string,
}
```

### Login/Register avec Google

**Route:** `GET /auth/google?redirect_url={REDIRECT_URL}`

**Paramètres d'URL requis:**

- `redirect_url`:  
  URL vers laquelle retourner une fois le flow terminé.  
  L'URL contiendra un paramètre d'URL supplémentaire avec le token d'authentification (`?token=SOME_TOKEN_HERE`)

**Réponse:**

Redirection vers la page de login de Google et, à la fin du flow, redirection avec code 202 vers `REDIRECT_URL` avec un token d'authentification ajouté dans l'URL.

API Routes
----------

### Information de compte

**Route:** `GET /api/v1/account/me`

**Réponse**: `200 OK`

**Corps de réponse (MIME: `application/json`):**

```ts
{
    user_id: string,
    email: string,
    name: string,
    using_google: boolean,
}
```

### Lister les feeds

**Route:** `GET /api/v1/feeds`

**Réponse:** 200 avec tous les feeds RSS du compte (articles non compris)

### Visualizer un feed spécifique

**Route:** `GET /api/v1/feed/{feed_id}`

**Réponse:** `200 OK` avec le feed RSS (articles non compris)

### S'abonner à un feed

**Route:** `PUT /api/v1/feeds`

**Corps de requête (MIME: `application/json`):**

```ts
{
    "url": string,
}
```

**Réponse:** `200 OK` avec corps vide

### Supprimer un feed

**Route:** `DELETE /api/v1/feed/{feed_id}`

**Réponse:** `200 OK` avec corps vide

### Lister les articles d'un feed

**Route:** `GET /api/v1/articles/{feed_id}`

**Réponse:** `200 OK` avec tous les articles du feed RSS (depuis le dernier refresh)

### Visualizer un article spécifique d'un feed

**Route:** `GET /api/v1/article/{article_id}`

**Réponse:** `200 OK` avec l'article du feed RSS (depuis le dernier refresh)

### Marquer un article spécifique d'un feed comme lu ou non-lu

**Route:** `POST /api/v1/article/{article_id}`

**Corps de requête (MIME: `application/json`):**

```ts
{
    "read": boolean,
}
```

**Réponse:** `200 OK` avec l'article du feed RSS (depuis le dernier refresh)

### Lister les categories de feeds RSS

**Route:** `GET /api/v1/categories`

**Réponse:** `200 OK` avec les categories de feeds

### Visualizer une categorie spécifique de feeds RSS

**Route:** `GET /api/v1/category/{category_name}`

**Réponse:** `200 OK` avec liste des feeds dans la categorie
