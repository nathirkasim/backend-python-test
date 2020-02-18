ARG DOCKER_BASE_IMAGE=python:3.8.0-slim
FROM ${DOCKER_BASE_IMAGE}

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python-dev
