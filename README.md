# Python Django Backend Starter
This is a starter project for a Django backend to get you started a little bit
faster. Replace this description for a description that is suitable for your
project, but keep the Usage section in place to inform other developers and
your future self how to use this project.

## Usage
This repository uses Docker images to simplify development and deployment of
your application.

Prior to starting development, you will need to [build a base
image](#build-base-image) which contains all the prerequisites that are common
between all your environments.

After your base image is built, you can develop your application by using this
base image to [run commands](#run-commands) that install packages and run your
application, tests and other tools.

In some cases, you may need to install dependencies for your development or
test environment that require more than a `pip install` and warrant [creating a
separate development image](#create-development-image).

### Build base image
The base image for this project is defined in base.Dockerfile and can be built
by running

```bash
make image
```


where the `BASE_IMAGE` defined in the Makefile defines the value used by the
`FROM` command in the Dockerfile.

Edit the base.Dockerfile as necessary to ensure that the common dependencies
are installed.

#### Caching

In case you want to avoid rebuilding all your images from scratch, prefix image
makerule calls with `DOCKER_CACHE_FLAG=""` in order to clear the default
`--no-cache` flag and thus allow caching in the docker build process.

```
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

could be built by running `APP_PATH=poetry-demo make image`.

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

could be built by running `make image` since the `APP_PATH` defaults to the
project root directory and we would need the dependencies manifest, being
requirements.txt in this case, to be included for a build to succeed.


### Run commands
To produce a development environment run `make bash` to pull the necessary
Docker image and drop into a bash shell therein.

### Install packages with `pip`
In order to run commands such as pip install commands to set up your
environment run

```bash
make run COMMAND="pip install --user Django"
````

to install the Django framework and its dependencies for example.

> Operating a Docker container as root is considered a bad practice, hence the
> design choice to run the container as a user which matches the uid and gid on
> the host thus resulting in read and write operations to mounted volumes being
> performed against the uid and gid from the user on the host who started the
> container (being yourself). This removes the need for the occasional
> recursive chown on your work directory on some Linux workstations.

See the [Django install page][pip-install] for more information regarding the
installation of the framework but keep the constraints of the Docker
environment in mind when executing commands referenced in that document.

> Note that the `--user` flag is used to instruct pip to install packages
> within the user's home directory i.e.: `~/.local` which avoid problems that
> would be caused by pip attempting to install packages to paths that require
> root permissions.

As customary with pip, you can produce a dump of all installed packages to the
requirements.txt file by running `pip freeze > requirements.txt` as in

```bash
make run COMMAND="pip freeze > requirements.txt"
```

and conversely install all packages listed in the requirements.txt file by
running

```bash
make run COMMAND="pip install -r requirements.txt"
```

[pip-install]: https://docs.djangoproject.com/en/3.0/topics/install/#installing-an-official-release-with-pip

### Clean environment
Use of the `pip install --user` command will populate the .local and .cache
directories with the installed packages and cached items respectively which,
along with other temporary files, can be cleaned up by running

```bash
make clean
```

whenever you need to clean up the environment.


> It is recommended to reset the environment before running a pip install based
> on a requirements.txt file to avoid situations where setups seem to be
> running because of some dangling packages that may no longer be captured
> within the requirements.txt file. Since we produce our production images
> based on the requirements.txt file, it is a good practice to rebuild from
> requirements.txt from time to time to ensure that the requirements.txt file
> is complete.

### Create development image
As documented in [Install packages with `pip`](#install-packages-with-pip)
above, Python's pip package manager can be used to install packages to a user
directory rather than directories that require root access and this project has
been designed to work best when packages are installed within a user-controller
path.

The manner in which this project's environment is set up, packages installed to
a user-controller path will be install into git-ignored folders within this
project's directory (because we run the container with this project directory
mounted as the container's home path) and therefore you may not need a
dedicated image for development.

If you happen to need a separate development image, consider adding the
following `dev-image` task to your Makefile

```Makefile
# Produce the development image based on dev.Dockerfile
dev-image:
	docker build \
		--build-arg="DOCKER_BASE_IMAGE=${DOCKER_NAME}:${DOCKER_TAG}-base" \
		--no-cache \
		--rm \
		--tag=${DOCKER_NAME}:${DOCKER_TAG}-dev \
		-f dev.Dockerfile \
		.
```

and note how the all non-base images are built on top of the `-base`-postfixed
image.

Follow the instructions above produce as many environments as necessary (e.g.:
a test image when you need a given lib pre-installed into the image for test
purposes) but keep in mind that keeping complexity low helps you reason about a
project and therefore less images to reason about, manage and to attempt to
maintain parity between may prove to be a more maintainable strategy.
