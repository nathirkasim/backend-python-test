ARG DOCKER_BASE_IMAGE=python:3.8.0-slim
FROM ${DOCKER_BASE_IMAGE}

# Install some system depedencies here that aren't part of the base image and
# follow the best practices documented on
# https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
