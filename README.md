# netronaut/strapi docker image

## Development

Use docker compose to run strapi in development.

First, copy `.env.example`:

```bash
cp .env.example .env
```

> ⚠️ TODO: add script to generate JWT and other secrets

Edit all keys and other required environment variables.

Then run the image using docker compose:

```bash
npm run docker:start
# docker compose up -d strapi
```

This will

- mount the directories `./config`, `./database`, `./public` and `./src`,
- map the standard strapi port `:1337`
- create a temporary sqlite database inside the container
- start strapi in watch mode (`strapi develop`)

Strapi will start at `http://localhost:1337`. Open it in the browser and set your admin email address and password.

Once you are finished creating your content model, don't forget to backup the database.

## Backup and restore

Run docker:backup and docker:restore scripts to interact with the database:

```bash
# backup data to seed.sql
npm run docker:backup

# restore data from seed.sql
npm run docker:restore
```

This will populate the file `seed.sql` from the temporary sqlite database.

## Run in production

To run strapi in production, you may want to

- configure a production db server
- import seed.sql to production db
- set up an upload provider (for storing media files)

### Configure database

Refer to strapi documentation on how to set up a database client: https://docs.strapi.io/developer-docs/latest/setup-deployment-guides/configurations/required/databases.html

Save your database config in `./config/env/production/database.js`.

### Configure upload provider

Refer to strapi docs for media upload providers like AWS S3: https://docs.strapi.io/developer-docs/latest/plugins/upload.html#using-a-provider

Your upload plugin configuration may well be saved to `./config/env/production/plugins.js`.

### Production image

The production image produced by `Dockerfile` is a bit smaller (520 instead of 830 MB). Run docker to produce the production-optimized docker image:

```bash
docker build -t netronaut/strapi:latest --target prod .
```
