# The following args have been provided default values but can be overriden
# from the CLI by specifying those variables with the override values.

# The path to the shippable part of your application.
# The shippable part of your application should contain manifest files
# (requirements.txt in case of pip, pyproject.toml and poetry.lock in case of
# Poetry) and the actual source that you will want to run inside of your
# container.
APP_PATH ?= ${PWD}

# Base image (as FROM) for all project images
# Try to use official images as much as possible.
# https://docs.docker.com/docker-hub/official_images/
BASE_IMAGE ?= python:3.8.0-slim

# Host address for port mapping
# Don't use 0.0.0.0 as this opens up your machine,
HOST ?= 127.0.0.1

# Port on host for port mapping to image
PORT ?= 8121

# Prefix for Docker images
PROJECT ?= backend-starter-django

# Version to use for tagging images.
VERSION ?= 0.1.0

DOCKER_CACHE_FLAG ?= "--no-cache"

DOCKER_CONTAINER_BASE_IMAGE = ${BASE_IMAGE}
DOCKER_CONTAINER_HOME_PATH = /home/appuser
DOCKER_CONTAINER_PORT = 8000 # Whatever the Django default port is

DOCKER_HOST_ADDRESS = ${HOST}
DOCKER_HOST_PROJECT_PATH = ${PWD}
DOCKER_HOST_PORT = ${PORT}

DOCKER_NAME = ${PROJECT}
DOCKER_TAG = ${VERSION}

DOCKER_ARGS = \
	-e "API_BASE_URL=http://localhost:${DOCKER_HOST_PORT}" \
	-e "PROJECT=${PROJECT}" \
	-e "HOME=${DOCKER_CONTAINER_HOME_PATH}" \
	-p ${DOCKER_HOST_ADDRESS}:${DOCKER_HOST_PORT}:${DOCKER_CONTAINER_PORT} \
	-u `id -u`:`id -g` \
	-v ${DOCKER_HOST_PROJECT_PATH}/.config:/etc/opt/${PROJECT} \
	-v ${DOCKER_HOST_PROJECT_PATH}/.homedir:${DOCKER_CONTAINER_HOME_PATH} \
	-v ${DOCKER_HOST_PROJECT_PATH}/.venv:/opt/venv \
	-v ${APP_PATH}:/tmp/${PROJECT} \
	-w /tmp/${PROJECT}

# Cleans up the temporary files
clean:
	rm -rf .venv .homedir/.cache

bash:
	@mkdir -p .venv
	@docker run \
		${DOCKER_ARGS} \
		--rm -it \
		-w ${APP_PATH} \
		${DOCKER_NAME}:${DOCKER_TAG}-dev bash

prod-image:
	@docker build \
		${DOCKER_CACHE_FLAG} \
		--build-arg="DOCKER_BASE_IMAGE=${DOCKER_CONTAINER_BASE_IMAGE}" \
		--build-arg="PROJECT=${PROJECT}" \
		--file=Dockerfile \
		--rm \
		--tag=${DOCKER_NAME} \
		--tag=${DOCKER_NAME}:${DOCKER_TAG} \
		--target=prod-image \
		${APP_PATH}

dev-image:
	@docker build \
		${DOCKER_CACHE_FLAG} \
		--build-arg="DOCKER_BASE_IMAGE=${DOCKER_CONTAINER_BASE_IMAGE}" \
		--build-arg="PROJECT=${PROJECT}" \
		--file=Dockerfile \
		--rm \
		--tag=${DOCKER_NAME}:${DOCKER_TAG}-dev \
		--target=dev-image \
		${APP_PATH}

.PHONY: prod-image dev-image bash clean
# vi: set nowrap:
