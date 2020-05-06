# Cancel implicit rules on top Makefile
$(CURDIR)/Makefile Makefile: ;

SHELL := /bin/bash

GIT_REMOTE_URL ?= $(shell git remote get-url origin)
GIT_SHA ?= $(shell git rev-parse HEAD)
GIT_BRANCH ?= $(shell git rev-parse --abbrev-ref HEAD | tr -s "[:punct:]" "-" | tr -s "[:upper:]" "[:lower:]")
GIT_CURRENT_VERSION_TAG ?= $(shell git tag --list "[0-9]*" --sort="-version:refname" --points-at HEAD | head -n 1)
GIT_LATEST_VERSION_TAG ?= $(shell git tag --list "[0-9]*" --sort="-version:refname" | head -n 1)

ifeq ($(GIT_BRANCH),HEAD)
ifneq ($(GIT_CURRENT_VERSION_TAG),)
GIT_BRANCH = master
GIT_LATEST_VERSION_TAG = $(GIT_CURRENT_VERSION_TAG)
else
$(error "Missing valid git version tag!")
endif
endif

PROJECT_DIR ?= $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
PROJECT_NAME ?= $(basename $(notdir $(GIT_REMOTE_URL)))

DOCKER_BUILD_OPTIONS ?= --pull --no-cache --force-rm --rm
DOCKER_PUSH_OPTIONS ?=
DOCKER_IMAGE_NAME ?= schul-cloud/riot-embed
DOCKER_PATH ?= docker.pkg.github.com/schul-cloud/$(PROJECT_NAME)/embed
DOCKER_VERSION_TAG ?= $(GIT_BRANCH)_v$(GIT_LATEST_VERSION_TAG)_$(GIT_SHA)
ifeq ($(GIT_LATEST_VERSION_TAG),)
DOCKER_VERSION_TAG = $(GIT_BRANCH)_$(GIT_SHA)
endif
DOCKER_SHA_TAG ?= $(GIT_SHA)

.PHONY: build
build: DOCKER_BUILD_OPTIONS += \
    -t $(DOCKER_IMAGE_NAME) \
	--build-arg USE_CUSTOM_SDKS=true \
    --build-arg REACT_SDK_REPO="https://github.com/schul-cloud/matrix-react-sdk.git" \
    --build-arg REACT_SDK_BRANCH="feature/embed" \
    --build-arg JS_SDK_REPO="https://github.com/matrix-org/matrix-js-sdk.git" \
    --build-arg JS_SDK_BRANCH="master" \
    --build-arg PUBLIC_PATH="https://embed.messenger.schule/" \
    --build-arg FROM_IMAGE="$(DOCKER_PATH):latest"
build:
	docker build $(DOCKER_BUILD_OPTIONS) "$(PROJECT_DIR)"

.PHONY: tag
tag:
	docker tag "$(DOCKER_IMAGE_NAME)" $(DOCKER_PATH):$(DOCKER_VERSION_TAG)
	docker tag "$(DOCKER_IMAGE_NAME)" $(DOCKER_PATH):$(DOCKER_SHA_TAG)
	docker tag "$(DOCKER_IMAGE_NAME)" $(DOCKER_PATH):latest

.PHONY: push
push: DOCKER_PUSH_OPTIONS +=
push:
	docker push $(DOCKER_PUSH_OPTIONS) $(DOCKER_PATH):$(DOCKER_VERSION_TAG)
	docker push $(DOCKER_PUSH_OPTIONS) $(DOCKER_PATH):$(DOCKER_SHA_TAG)
	docker push $(DOCKER_PUSH_OPTIONS) $(DOCKER_PATH):latest
