# Do not provide a default base image in order to make this definition explicit
ARG DOCKER_BASE_IMAGE


FROM ${DOCKER_BASE_IMAGE} AS compile-image

# Install dependencies for psycopg2
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    python-dev \
    && rm -rf /var/lib/apt/lists/*

# Define environment vars for venv and produce the venv directory
ENV VIRTUAL_ENV=/opt/venv
RUN python -m venv /opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

WORKDIR /tmp/app
COPY requirements.txt .
RUN pip install -r requirements.txt


FROM ${DOCKER_BASE_IMAGE}

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

# Define environment vars for venv and produce the venv directory
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

COPY --chown=${UID}:${GID} --from=compile-image /opt/venv /opt/venv

ARG PROJECT
ENV PROJECT=${PROJECT}
WORKDIR /opt/${PROJECT}

# Explicitly listing all files to be copied as opposed to listing non-wanted
# files in a .dockerignore file makes it easier to examine (e.g.: during
# code-reviews) which files will be shipped with builds. Relying on
# .dockerignore as the primary means to manage the assets for build images is
# arguably less secure.
# As a rule of thumb, use the .dockerignore file to reduce the build context
# and avoid using it as the primary means to keep files from ending up in
# production images.
# Prefer COPY of ADD
COPY --chown=${UID}:${GID} mysite /opt/${PROJECT}/mysite
