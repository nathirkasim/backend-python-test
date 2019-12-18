# The following args have been provided default values but can be overriden
# from the CLI by specifying those variables with the override values.
BASE_IMAGE=python:3.8.0-slim
COMMAND=echo test; exit 1
HOST=127.0.0.1
IMAGE_NAME=backend-django
IMAGE_TAG=0.1.0
PORT=8121

DOCKER_CONTAINER_BASE_IMAGE?=${BASE_IMAGE}
DOCKER_CONTAINER_COMMAND=bash
DOCKER_CONTAINER_HOMEDIR=/home/${DOCKER_CONTAINER_USERNAME}
DOCKER_CONTAINER_IMAGE=python:3.8.0-slim
DOCKER_CONTAINER_PORT?=8000 # Whatever the Django default port is
DOCKER_CONTAINER_USERNAME=developer
DOCKER_HOST_ADDRESS?=${HOST}
DOCKER_HOST_HOMEDIR=${PWD}
DOCKER_HOST_PORT?=${PORT}

DOCKER_IMAGE?=${IMAGE_NAME}
DOCKER_TAG?=${IMAGE_TAG}

DOCKER_ARGS=\
	-e "API_BASE_URL=http://localhost:${DOCKER_HOST_PORT}" \
	-e "HOME=${DOCKER_CONTAINER_HOMEDIR}" \
	-e "PYTHONPATH=${DOCKER_CONTAINER_HOMEDIR}" \
	-p ${DOCKER_HOST_ADDRESS}:${DOCKER_HOST_PORT}:${DOCKER_CONTAINER_PORT} \
	-u `id -u`:`id -g` \
	-v ${DOCKER_HOST_HOMEDIR}:${DOCKER_CONTAINER_HOMEDIR} \
	-w ${DOCKER_CONTAINER_HOMEDIR} \

nuke:
	rm -rf .local .cache

run:
	docker run \
		${DOCKER_ARGS} \
		--rm -it \
		${DOCKER_CONTAINER_BASE_IMAGE} ${COMMAND}

bash:
	docker run \
		${DOCKER_ARGS} \
		--rm -it \
		${DOCKER_CONTAINER_BASE_IMAGE} bash

image:
	docker build \
		--build-arg="DOCKER_BASE_IMAGE=${DOCKER_CONTAINER_BASE_IMAGE}" \
		--no-cache \
		--rm \
		--tag=${DOCKER_IMAGE} \
		--tag=${DOCKER_IMAGE}:${DOCKER_TAG} \
		.

.PHONY: bash images nuke run
