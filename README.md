# Python Django Backend Starter

This is a starter project for a Django backend to get you started a little bit
faster. Replace this description for a description that is suitable for your
project, but keep the Usage section in place to inform other developers and
your future self how to use this project.

## Usage

To produce a development environment run `make bash` to pull the necessary
Docker image and drop into a bash shell therein.

For the sake of convenience, you can run individual commands that you would run
within the bash shell by passing them through the COMMAND variable to the `run`
task as demonostrated below:

```bash
make run COMMAND="python --version"
```

> The rest of this document uses the `make run` form to display commands for
> simplicity's sake with the assumption that you understand that commands can
> be entered directly into a bash session produced by `make bash`.

### Package installation with `pip`

In order to run commands such as pip install commands to set up your
environment run

```bash
make run COMMAND="pip install --user Django"
````

to install the Django framework and its dependencies for example.

> Operating a Docker container as root is considered a bad practice, hence the
> design choice to run the container as a user which matches the uid and gid on
> the host thus resulting to IO to mounted volumes being performed against the
> uid and gid from the user on the host who started the container (yourself).
> This removes the need for the occassional recursive chown on your work
> directory on some Linux workstations.

See the [Django install page][pip-install] for more information regarding the
installation of the framework but keep the constraints of the Docker
environment in mind when executing commands referenced in that document.


> Note that the `--user` flag is used to instruct pip to install packages
> within the user's home directory i.e.: `~/.local` which avoid problems that
> would be caused by pip attempting to install packages to paths that require
> root permissions. Since operating a container as a root user is generally
> considered a bad practice, we would recommend to stick to the convention of
> installing packages into the user's home directories.


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

### Environment reset

Use of the `pip install --user` command will populate the .local and .cache
directories with the installed packages and cached items respectively which,
along with other temporary files, can be cleared by running

```bash
make nuke
```

whenever you need to reset the environment.


> It is recommended to reset the environment before running a pip install based
> on a requirements.txt file to avoid situations where setups seem to be
> running because of some dangling packages that may no longer be captured
> within the requirements.txt file. Since we produce our production images
> based on the requirements.txt file, it is a good practice to rebuild from
> requirements.txt from time to time to ensure that the requirements.txt file
> is complete.
