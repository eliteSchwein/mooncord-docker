ARG VERSION="1.2.1"
ARG NODE_VERSION="20"
ARG NODE_BUILD_VERSION="18"

# Build stage: Install dependencies and build application
FROM node:${NODE_BUILD_VERSION}-alpine as build

WORKDIR /app

# Fetch the application source
ARG VERSION
RUN wget -qO- https://github.com/eliteSchwein/mooncord/archive/refs/tags/v${VERSION}.tar.gz | tar -xz --strip-components=1

# Install Node.js dependencies
RUN npm ci --omit=dev --prefer-offline --no-audit

# Final stage: Use a clean runtime image
FROM node:${NODE_VERSION}-alpine

# Install runtime dependencies
RUN apk add --no-cache ffmpeg graphicsmagick

# Copy necessary files and binaries from the build stage
COPY --from=build /app /app

# Copy configuration and entrypoint scripts
COPY defaults/mooncord.cfg /config/mooncord.cfg
COPY defaults/ /defaults/
COPY entrypoint.sh /entrypoint.sh

# Set permissions
RUN chmod +x /entrypoint.sh && \
    mkdir -p /config && \
    chown -R node:node /config

# Switch to non-root user
USER node
WORKDIR /app

# Set entrypoint and default command
ENTRYPOINT ["/entrypoint.sh"]
CMD ["node", "--expose-gc", "--max-old-space-size=64", "/app/dist/index.js", "/config"]
