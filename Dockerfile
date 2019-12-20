ARG DOCKER_BASE_IMAGE=python:3.8.0-slim
FROM ${DOCKER_BASE_IMAGE}

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
