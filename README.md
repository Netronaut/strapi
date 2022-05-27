# Docker image for strapi.io headless CMS

This Docker image contains a pre-installed version of strapi.io headless CMS.

Strapi and base dependencies are already installed in `node_modules`.

Additionally there's sqlite installed to create and restore backups (see [Backup](#backup)).

## Run image

Strapi needs API secrets to run. Provide these via `.env`-file:

```ini
APP_KEYS=<array of four keys, separated by comma>
JWT_SECRET=<key>
API_TOKEN_SALT=<key>
```

You may generate an `.env` file with api keys using this script:

```bash
node ./generate-api-keys.js > .env
```

Now run strapi. Don't forget to attach ports and any volume you need:

```bash
docker run --rm --env-file .env --name netronaut_strapi -d -p 1337:1337 netronaut/strapi
```

Volumes to mount:

```Dockerfile
VOLUME /srv/app/config
VOLUME /srv/app/database
VOLUME /srv/app/public
VOLUME /srv/app/src
```

Most of the time you want to mount `/srv/app/src` in order to develop.

To extend strapi with extensions and custom configuration, use the `/srv/app/config` volume.

Example:

```bash
docker run
  --rm
  --env-file .env
  --name netronaut_strapi
  -p 1337:1337
  -v `pwd`/src:/srv/app/src
  -d
  netronaut/strapi
```

### Compose file

You may want to use `docker compose` or another CLI to run from a docker-compose.yml like this:

```yml
version: '3'
services:
  strapi:
    image: netronaut/strapi
    volumes:
      - './strapi/src:/srv/app/src'
      - './strapi/config:/srv/app/config'
    ports:
      - 1337:1337
    env_file:
      - .env
```

## Database

This image works with sqlite per default. The data is stored inside the container under `<WORKDIR>/.tmp/data.db`.

You can use sqlite during development. Once you are ready to go to production, you might want to dump the data to an .sql file.

### Backup

Backup data to .sql file:

```bash
docker exec netronaut_strapi sh -c 'sqlite .tmp/data.db ".dump"' > backup.sql
```

### Restore

Restore the database from .sql file:

```bash
docker cp backup.sql netronaut_strapi:/srv/app/backup.sql
```

```bash
docker exec netronaut_strapi sh -c 'sqlite .tmp/data.db ".read backup.sql"'
```
