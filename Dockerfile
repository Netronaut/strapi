FROM node:16-alpine

ENV HOST=0.0.0.0
ENV PORT=1337
ENV APP_KEYS=
ENV JWT_SECRET=
ENV API_TOKEN_SALT=

EXPOSE $PORT

WORKDIR /srv/app

COPY package.json package.json
COPY package-lock.json package-lock.json
COPY config/ config/
COPY database/ database/
COPY favicon.ico favicon.ico
COPY public/ public/
COPY src/ src/

VOLUME /srv/app/config
VOLUME /srv/app/database
VOLUME /srv/app/public
VOLUME /srv/app/src

RUN apk --no-cache add --virtual native-deps \
  g++ gcc libgcc libstdc++ linux-headers make python3 && \
  ln -s /usr/bin/python3 /usr/bin/python && \
  ln -s /usr/bin/pip3 /usr/bin/pip && \
  npm install && \
  apk del native-deps

RUN apk --no-cache add sqlite && \
  ln -s /usr/bin/sqlite3 /usr/bin/sqlite

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

ENV NODE_ENV=development
CMD ["npm", "run", "dev"]
