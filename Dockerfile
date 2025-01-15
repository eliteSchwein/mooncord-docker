FROM node:20-alpine as build

RUN apk add --no-cache tini ffmpeg git

WORKDIR /app
RUN git clone --depth 1 --no-tags https://github.com/eliteSchwein/mooncord .
RUN npm ci --only=prod

FROM node:20-alpine
COPY --from=build /sbin/tini /sbin/tini
COPY --from=build /app /app

USER node
WORKDIR /app
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "/app/dist/index.js", "/config"]
