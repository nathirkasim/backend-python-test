# The following args have been provided default values but can be overriden
# from the CLI by specifying those variables with the override values.

# Base image (as FROM) for all project images
# Try to use official images as much as possible.
# https://docs.docker.com/docker-hub/official_images/
BASE_IMAGE ?= python:3.8.0-slim

# Default command of `make run` task unless otherwise specified by user
# Leave this as-is to send a friendly reminder to users when they have
# forgotten to set this variable on a `make run` call.
COMMAND ?= echo -e "\033[1;31mCOMMAND is undefined.\033[0m"

# Host address for port mapping
# Don't use 0.0.0.0 as this opens up your machine,
HOST ?= 127.0.0.1

# Port on host for port mapping to image
PORT ?= 8121

# Prefix for Docker images
PROJECT ?= backend-starter-django

# Version to use for tagging images.
VERSION ?= 0.1.0

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
	-v ${DOCKER_HOST_PROJECT_PATH}/.venv:/etc/opt/venv \
	-v ${DOCKER_HOST_PROJECT_PATH}:/opt/${PROJECT} \
	-w /opt/${PROJECT}

# Cleans up the temporary files
clean:
	rm -rf .local .cache

# Runs the command in the COMMAND var within the container
run:
	docker run \
		${DOCKER_ARGS} \
		--rm -it \
		${DOCKER_NAME}:${DOCKER_TAG}-base ${COMMAND}

bash:
	docker run \
		${DOCKER_ARGS} \
		--rm -it \
		${DOCKER_NAME}:${DOCKER_TAG} bash

image:
	docker build \
		--build-arg="DOCKER_BASE_IMAGE=${DOCKER_CONTAINER_BASE_IMAGE}" \
		--build-arg="PROJECT=${PROJECT}" \
		--no-cache \
		--rm \
		--tag=${DOCKER_NAME} \
		--tag=${DOCKER_NAME}:${DOCKER_TAG} \
		.

.PHONY: image bash clean run
# vi: set nowrap:
