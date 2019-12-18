# Python Django Backend Starter

## Usage

In order to run commands such as pip install commands to set up your
environment run 

```bash
make run COMMAND="pip install --user Django"
````

but note the `--user` flag which is used to instruct pip to install packages
within the user's home directory i.e.: `~/.local`.


Use of the `pip install --user` command will populate the .local and .cache
directories with the installed packages and cached items respectively which,
along with other temporary files, can be cleared by running 

```bash
make nuke
```

whenever you need to reset the environment.


As customary with pip, you can produce a requirements.txt file by running `pip
freeze > requirements.txt` as demonstrated below:

```bash
make run COMMAND="pip freeze > requirements.txt"
```

See the [Django install page] for more information regarding the installation
of the framework but keep the constraints of the Docker environment in mind
when executing commands referenced in that document.

> Operating a Docker container as root is considered a bad practice, hence the
> design choice to specify the user id of the host user, which results to IO to
> mounted volumes being performed against the uid and gid known to the host,
> therefore removing the need for the occassional recursive chown on your work
> directory on some Linux workstations.

[pip-install]: https://docs.djangoproject.com/en/3.0/topics/install/#installing-an-official-release-with-pip
