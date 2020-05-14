ARG NODE_IMAGE_TAG="10.20.1"
ARG NGINX_IMAGE_TAG="1.17.10-alpine"

# --- stage:builder ------------------------------------------------------------
FROM node:${NODE_IMAGE_TAG} as builder

# Support custom branches of the react-sdk and js-sdk. This also helps us build
# images of riot-web develop.
ARG USE_CUSTOM_SDKS=false
ARG REACT_SDK_REPO="https://github.com/matrix-org/matrix-react-sdk.git"
ARG REACT_SDK_BRANCH="master"
ARG JS_SDK_REPO="https://github.com/matrix-org/matrix-js-sdk.git"
ARG JS_SDK_BRANCH="master"

ARG BUILD_BRANCH
ARG BUILD_HASH

LABEL build.stage="builder"
LABEL build.branch="${BUILD_BRANCH}"
LABEL build.hash="${BUILD_HASH}"

RUN apt-get update && apt-get install -y git dos2unix

WORKDIR /src

COPY . /src
RUN dos2unix /src/scripts/docker-link-repos.sh && bash /src/scripts/docker-link-repos.sh
RUN yarn --network-timeout=100000 install
RUN yarn build

# Copy the config now so that we don't create another layer in the app image
RUN cp /src/config.sample.json /src/webapp/config.json

# Ensure we populate the version file
RUN dos2unix /src/scripts/docker-write-version.sh && bash /src/scripts/docker-write-version.sh

# --- stage:release ------------------------------------------------------------
FROM nginx:${NGINX_IMAGE_TAG} as release

ARG BUILD_BRANCH
ARG BUILD_HASH

LABEL build.stage="release"
LABEL build.branch="${BUILD_BRANCH}"
LABEL build.hash="${BUILD_HASH}"

COPY --from=builder /src/webapp /app

# Insert wasm type into Nginx mime.types file so they load correctly.
RUN sed -i '3i\ \ \ \ application/wasm wasm\;' /etc/nginx/mime.types

RUN rm -rf /usr/share/nginx/html \
 && ln -s /app /usr/share/nginx/html
