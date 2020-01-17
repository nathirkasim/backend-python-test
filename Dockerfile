# Do not provide a default base image in order to make this definition explicit
ARG DOCKER_BASE_IMAGE
FROM ${DOCKER_BASE_IMAGE}

# Define environment vars for venv and produce the venv directory
ENV VIRTUAL_ENV=/home/appuser/venv
RUN python -m venv /home/appuser/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Create the source directory, set appuser's ~ as the working path and install
# the dependencies listed in requirements.txt
RUN mkdir /home/appuser/src
WORKDIR /home/appuser
COPY requirements.txt src/.
RUN pip install -r src/requirements.txt

# TODO: Uninstall dependencies that were only needed for development

# Explicitly listing all files to be copied as opposed to listing non-wanted
# files in a .dockerignore file makes it easier to examine (e.g.: during
# code-reviews) which files will be shipped with builds. Relying on
# .dockerignore as the primary means to manage the assets for build images is
# arguably less secure.
# As a rule of thumb, use the .dockerignore file to reduce the build context
# and avoid using it as the primary means to keep files from ending up in
# production images.
# Prefer COPY of ADD
ARG APP_PACKAGE
COPY ${APP_PACKAGE} /home/appuser/src/${APP_PACKAGE}
