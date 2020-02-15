# Python Django Backend Starter
This is a starter project for a Django backend to get you started a little bit
faster. Replace this description for a description that is suitable for your
project, but keep the Usage section in place to inform other developers and
your future self how to use this project.

## Usage
This repository uses Docker images to simplify development and deployment of
your application.

Prior to starting development, you will need to [build the development
image](#build-images) which contains all the system dependencies that are
common between all your environments.

After your development image is built, you can develop your application by
dropping into a shell and [running the needed commands](#run-commands) that
install packages and run your application, tests and other tools.

### Build images
In Dockerfile, targets are defined for a `dev-image` (development image) and a
`prod-image` (production image). The development image is used to compile all
system packages and needed Python dependencies and the `app-image` is basically
composed by copying the needed build outputs from the `dev-image`.

Run `make dev-image` to produce the development image and run `make prod-image`
to produce the production image. Since these different environments are defined
as targets, one does not need to worry about running `make dev-image` before
`make image` as any image rule will suffice on its own to produce the needed
output.


#### Base Image
Both images are built on top of one of the official Python images as the base
image. By setting `BASE_IMAGE`, one may alter the base image used in both the
development and the production images.

```bash
BASE_IMAGE=python:3.8.0-slim make prod-image
```

#### Caching
In case you want to avoid rebuilding all your images from scratch, prefix image
makerule calls with `DOCKER_CACHE_FLAG=""` in order to clear the default
`--no-cache` flag and thus allow caching in the docker build process.

```bash
DOCKER_CACHE_FLAG="" make image
```

#### Application Path
In case the shippable part of your application is not equal to the root
directory of this repository you may use `APP_PATH` which defaults to `.` (the
project root directory) to specify the path of your application.


Note that a directory tree for a project structured as:

```
.
├── Dockerfile
├── install.sh
├── LICENSE
├── Makefile
├── NOTES.md
├── poetry-demo
│   ├── poetry_demo
│   ├── poetry_demo.egg-info
│   ├── poetry.lock
│   ├── pyproject.toml
│   ├── README.rst
│   └── tests
└── README.md
```

could be built by running `APP_PATH=poetry-demo make prod-image`.

> For the sake of cleanliness, we would recommend to keep application source
> and the relevant dependecies manifests within a subdirectory of the project
> root directory as this design keeps mounting of directories into the Docker
> container relatively easy to reason about.

A project structured as:

```
.
├── Dockerfile
├── install.sh
├── LICENSE
├── Makefile
├── mysite
│   ├── db.sqlite3
│   ├── manage.py
│   ├── mysite
│   ├── polls
│   └── templates
├── NOTES.md
└── requirements.txt
```

could be built by running `make prod-image` since the `APP_PATH` defaults to
the project root directory and we would need the dependencies manifest, being
requirements.txt in this case, to be included for a build to succeed.


### Run commands
In order to produce a Bash shell in which you can run arbitrary commands, run
`make bash`.

### Clean environment
Run `make clean` to remove the venv directory and the caches in order in case
you want to start from a clean slate. The clean makerule is only helpful to
clean the state of the bash shells that one can spawn through `make bash`. Any
image makerules will remain unaffected by the the caches or venv states on the
host.

> If you're using pip, it is recommended to reset the environment before
> running a pip install based on a requirements.txt file to avoid situations
> where setups seem to be running locally because of lingering packages that
> may no longer be captured within the requirements.txt file. This would result
> to builds failing with colleagues or on different systems such as your CI/CD
> pipelines.
