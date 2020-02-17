# The Docker "context" is the working directory for Docker which, for this
# setup, is set to the value of the APP_PATH variable in the Makefile. In case
# of a misconfiguration where the needed files are not found at the root of the
# APP_PATH directory, COPY commands are expected to fail. The files of interest
# within the Docker context are the Python dependency manifests, which are
# requirements.txt files when using pip as a package manager or pyproject.toml
# and poetry.lock when using Poetry as a package manager. It's up to you to
# ensure that you copy the appropriate dependency manifests for the package
# manager that you have chosen but we would recommend you stick to Poetry just
# to keep things simpler for you and your team.

# Do not provide a default base image in order to make this choice explicit
ARG DOCKER_BASE_IMAGE


FROM ${DOCKER_BASE_IMAGE} AS dev-image

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    libpq-dev \
    python-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry to $POETRY_HOME and allow all users to execute Poetry binaries
# https://python-poetry.org/docs/#introduction
ENV POETRY_HOME=/opt/poetry
RUN curl -sSL \
  https://raw.githubusercontent.com/python-poetry/poetry/1.0.3/get-poetry.py \
  > /tmp/get-poetry.py && \
  python /tmp/get-poetry.py && \
  chmod -R a+x ${POETRY_HOME}/bin

# Define environment vars for venv and initialize a venv
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:/opt/poetry/bin/:$PATH"
RUN python -m venv /opt/venv

ARG PROJECT=app
ENV PROJECT=${PROJECT}
WORKDIR /tmp/${PROJECT}

# Copy Python dependency manifests and install listed dependencies
COPY pyproject.toml poetry.lock /tmp/${PROJECT}/
RUN poetry install --no-dev


FROM ${DOCKER_BASE_IMAGE} AS prod-image

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

ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

COPY --chown=${UID}:${GID} --from=dev-image /opt/venv /opt/venv

ARG PROJECT=app
ENV PROJECT=${PROJECT}
WORKDIR /opt/${PROJECT}

# Explicitly listing all files to be copied as opposed to listing non-wanted
# files in a .dockerignore file makes it easier to examine (e.g.: during
# code-reviews) which files will be shipped with builds. Relying on
# .dockerignore as the primary means to manage the assets for build images is
# arguably less secure as it doesn't explicitly require approval or listing of
# assets prior to them finding their way into a shipped image.
# As a rule of thumb, use the .dockerignore file to reduce the build context
# and avoid using it as the primary means to keep files from ending up in
# images mean for deployment.
# Prefer COPY over ADD
COPY --chown=${UID}:${GID} . /opt/${PROJECT}/

# Start service
EXPOSE 8000
ENTRYPOINT ["gunicorn"]
CMD [ "--bind=0.0.0.0:8000", "--worker-class=sanic.worker.GunicornWorker", "sanic_openapi_example.main:app" ]
