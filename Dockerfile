ARG NODE_VERSION="node:16-alpine"

# Stage: dev
#
# This stage is designed to run with mounted folders
# /src, /config, /database, /public on the host.
#
# It copies seed.sql and uses sqlite3 to prime the database.
# To get a data dump after editing the model, use `npm run docker:backup`.
#
# Make sure to backup the database regularily or map .tmp to a host volume.
FROM $NODE_VERSION as dev

WORKDIR /srv/app
VOLUME /srv/app/src
VOLUME /srv/app/config
VOLUME /srv/app/database
VOLUME /srv/app/public

COPY package.json package.json
COPY package-lock.json package-lock.json
COPY seed.sql seed.sql
COPY favicon.ico favicon.ico

RUN apk --no-cache add \
  g++ gcc libgcc libstdc++ linux-headers make python3 sqlite && \
  ln -s /usr/bin/python3 /usr/bin/python && \
  ln -s /usr/bin/pip3 /usr/bin/pip && \
  ln -s /usr/bin/sqlite3 /usr/bin/sqlite

RUN npm install
RUN mkdir .tmp && cat seed.sql | sqlite .tmp/data.db

ENV NODE_ENV=development
CMD npm run dev

# Stage: build
#
# This stage is an intermediary stage to 'prod'.
# It installs the required dependencies and builds the strapi server.
FROM $NODE_VERSION as build

WORKDIR /srv/app

COPY package.json package.json
COPY package-lock.json package-lock.json
COPY config/ config/
COPY src/ src/

RUN apk --no-cache add --virtual native-deps \
  g++ gcc libgcc libstdc++ linux-headers make python3 && \
  ln -s /usr/bin/python3 /usr/bin/python && \
  ln -s /usr/bin/pip3 /usr/bin/pip && \
  npm ci --production && \
  apk del native-deps

RUN NODE_ENV=production npm run build

# Stage: prod
#
# This is the build stage intended for production builds.
# It contains the minimal dependencies. Database is supposed to be
# configured as an external server.
FROM $NODE_VERSION as prod

WORKDIR /srv/app

COPY --from=build /srv/app/package.json package.json
COPY --from=build /srv/app/package-lock.json package-lock.json
COPY --from=build /srv/app/node_modules/ node_modules/
COPY --from=build /srv/app/build/ build/
COPY --from=build /srv/app/config/ config/
COPY src/ src/
COPY public/ public/
COPY favicon.ico favicon.ico

ENV NODE_ENV=production
CMD npm start
