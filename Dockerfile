FROM node:18.16.0-alpine as build

USER root

WORKDIR /app

# Install dependencies
RUN apk update && apk add --no-cache python3 build-base chromium curl tar

ENV VERSION="v0.18.9"
# Set PYTHON env
ENV PYTHON=/usr/bin/python3

# Fetch the release tarball and extract it
RUN curl -L https://github.com/bigcapitalhq/bigcapital/archive/refs/tags/${VERSION}.tar.gz | tar xz --strip 1
RUN ls
# Copy application dependency manifests to the container image.


# Install pnpm and dependencies
RUN npm install -g pnpm
RUN pnpm install

# Build webapp package
#COPY ./packages/webapp /app/packages/webapp
RUN pnpm run build:webapp

# Runtime stage
FROM node:18.16.0-alpine

USER root

WORKDIR /app

# Copy the built files from the build stage
COPY --from=build /app/packages/webapp/build /app/build

# Install `serve` to serve the static files
RUN npm install -g serve

# Expose the port the app runs on
EXPOSE 3000

# Start the application
CMD ["serve", "-s", "build", "-l", "3000"]
