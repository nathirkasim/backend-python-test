# The following args have been provided default values but can be overriden
# from the CLI by specifying those variables with the override values or by
# declaring those variables in the project.mk file which is conditionally
# included after variable declaration in this Makefile.

# The path to the shippable part of your application.
# The shippable part of your application should contain manifest files
# (requirements.txt in case of pip, pyproject.toml and poetry.lock in case of
# Poetry) and the actual source that you will want to run inside of your
# container.
APP_PATH ?= .

# Base image (as FROM) for all project images
# Try to use official images as much as possible.
# https://docs.docker.com/docker-hub/official_images/
BASE_IMAGE ?= python:3.8.0-slim

# Host address for port mapping
# Don't use 0.0.0.0 as this opens up your machine,
HOST ?= 127.0.0.1

# Port on host to be mapped into the container
PORT ?= 8121

# Prefix for Docker images
PROJECT ?= backend-starter-django

# Version to use for tagging images.
VERSION ?= 0.1.0


# Docker container parameters

# Docker image to use as a source for development and production images
DOCKER_CONTAINER_BASE_IMAGE = ${BASE_IMAGE}

# Home path of the container in order to adequately mount .homedir
DOCKER_CONTAINER_HOME_PATH = /home/appuser

# Port of the container to which to map the host
DOCKER_CONTAINER_PORT = 8000


# Docker host parameters

# IP address or hostname of the host, defaults to the ${HOST} loopback address
DOCKER_HOST_ADDRESS = ${HOST}

# Port of the host, defaults to ${PORT}
DOCKER_HOST_PORT = ${PORT}

# Path of the project of interest, defaults to the current working directory
DOCKER_HOST_PROJECT_PATH = ${PWD}

# Docker image name
DOCKER_NAME = ${PROJECT}

# Docker image tag
DOCKER_TAG ?= ${VERSION}

# Caching flag for Docker build process
# Disable caching to force the docker builder to always rebuild all layers and
# thus minimize the chances of cached layers providing a false sense of build
# validity. If a build is broken because some resource is no longer available
# from the registries, you would need to know this as soon as possible i.e.:
# before hitting production environments.
DOCKER_CACHE_FLAG ?= "--no-cache"

# Define the command line arguments to use in spawning Docker runs.
# - Defines environment variables (-e)
# - Defines port mappings (-p)
# - Sets the UID and GID to those of the host user (-u)
#   Ensures sensible ownership defaults on Linux hosts
# - Mounts volumes (-v)
# - Sets working directory (-w)
DOCKER_ARGS = \
	-e "PROJECT=${PROJECT}" \
	-e "HOME=${DOCKER_CONTAINER_HOME_PATH}" \
	-p ${DOCKER_HOST_ADDRESS}:${DOCKER_HOST_PORT}:${DOCKER_CONTAINER_PORT} \
	-u `id -u`:`id -g` \
	-v ${DOCKER_HOST_PROJECT_PATH}/.config:/etc/opt/${PROJECT} \
	-v ${DOCKER_HOST_PROJECT_PATH}/.homedir:${DOCKER_CONTAINER_HOME_PATH} \
	-v ${DOCKER_HOST_PROJECT_PATH}/.venv:/opt/venv \
	-v `realpath ${APP_PATH}`:/tmp/${PROJECT} \
	-w /tmp/${PROJECT}

# Include the project.mk file if it exists and allow for all variables thusfar
# defined to be overriden.
-include project.mk

# Remove temporary files
clean:
	@rm -rf .homedir/.cache .venv

# Spawn a Bash shell for the development image
bash:
	@mkdir -p .config .venv ${APP_PATH}
	docker run \
		${DOCKER_ARGS} \
		--rm -it \
		${DOCKER_NAME}:${DOCKER_TAG}-dev bash

# Build production image
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

# Build development image
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
