ARG DOCKER_BASE_IMAGE=python:3.8.0-slim
FROM ${DOCKER_BASE_IMAGE}

ENV VIRTUAL_ENV=/home/appuser/venv
RUN python -m venv /home/appuser/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN mkdir /home/appuser/src
WORKDIR /home/appuser
COPY requirements.txt src/.
RUN pip install -r src/requirements.txt

# TODO: Uninstall dependencies that were only needed for development
