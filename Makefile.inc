# Check if its included in a Makefile(.*)
ifneq ($(notdir $(firstword $(MAKEFILE_LIST))),Makefile)
$(error ERROR: This file has to be included in Makefile)
endif

# Expands build target from Makefile
.PHONY: build
build:: DOCKER_BUILD_OPTIONS += \
	--build-arg USE_CUSTOM_SDKS=true \
	--build-arg REACT_SDK_REPO="https://github.com/schul-cloud/matrix-react-sdk.git" \
	--build-arg REACT_SDK_BRANCH="feature/embed" \
	--build-arg JS_SDK_REPO="https://github.com/matrix-org/matrix-js-sdk.git" \
	--build-arg JS_SDK_BRANCH="master"

# Expands run target from Makefile
.PHONY: run
run:: DOCKER_RUN_OPTIONS += \
	--publish-all \
	--volume "$$(pwd)"/nginx-embed.conf:/etc/nginx/conf.d/default.conf
