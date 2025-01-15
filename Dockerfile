ARG VERSION="1.2.1"
ARG NODE_VERSION="20"

FROM node:${NODE_VERSION}-alpine as build

RUN apk add --no-cache tini ffmpeg git graphicsmagick

WORKDIR /app
ARG VERSION
RUN wget -qO- https://github.com/eliteSchwein/mooncord/archive/refs/tags/v${VERSION}.tar.gz | tar -xz --strip-components=1
RUN npm ci --only=prod

FROM node:${NODE_VERSION}-alpine

COPY --from=build /sbin/tini /sbin/tini
COPY --from=build /app /app

COPY defaults/mooncord.cfg /config/mooncord.cfg
COPY defaults/ /defaults/
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

RUN mkdir -p /config && chown -R node:node /config

USER node
WORKDIR /app

# Set the script as the default entrypoint
ENTRYPOINT ["/entrypoint.sh"]

CMD ["node", "/app/dist/index.js", "/config"]
