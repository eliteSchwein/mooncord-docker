FROM node:20-alpine

WORKDIR /app

USER node

RUN apk add --no-cache tini ffmpeg git

RUN git clone --depth 1 --no-tags https://github.com/eliteSchwein/mooncord .

RUN npm ci --only=prod

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "/app/dist/index.js", "/config"]