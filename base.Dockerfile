ARG DOCKER_BASE_IMAGE=python:3.8.0-slim
FROM ${DOCKER_BASE_IMAGE}

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python-dev \
    && rm -rf /var/lib/apt/lists/*

ARG GID=20000
ARG UID=20000
ARG GECOS=",,,,"
RUN \
  addgroup \
    --gid ${GID} \
    appgroup \
  && \
  adduser \
    --uid ${UID} \
    --gecos ${GECOS} \
    --gid ${GID} \
    --disabled-password \
    --disabled-login \
    appuser
USER ${UID}:${GID}
