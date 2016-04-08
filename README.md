# Rack on Docker

### Description

This is an example on how one can run rack web server with postgres database and volume sharing on unicorn via nginx in docker container.

### Usage/Tips

#### TL;DR
* To build images type:
  * `docker build --tag placek/rack_on_docker .`
* To run `data-only` container type:
  * `docker run --name data_container --volume /www/public/uploads busybox true`
* To run `postgres` container type:
  * `docker run --name postgres_container --env POSTGRES_PASSWORD=lolopolo --detach postgres`
* To run `rack_on_docker` container type:
  * `docker run --publish-all --volumes-from data_container --link postgres_container:postgres --name rack_on_docker_container --detach placek/rack_on_docker`
* To access `rack_on_docker` container type:
  * `docker run --interactive --tty --rm --volumes-from data_container --link postgres_container:postgres placek/rack_on_docker /bin/bash` (to access it from separate container - recommended)
  * `docker exec --interactive --tty rack_on_docker_container /bin/bash` (to access running `rack_on_docker` container directly)
* To terminate containers type:
  * `docker kill rack_on_docker_container && docker rm rack_on_docker_container`
  * `docker rm data_container` (warning - it will remove the uploaded files)
  * `docker rm --force postgres_container` (warning - it will remove the database)
* To run tests type:
  * `docker run --tty --interactive --env RACK_ENV=test --rm placek/rack_on_docker /bin/bash -c 'bundle exec rake db:schema:load && bundle exec rspec'`

#### Data-only container

* To launch data-only container run `docker run --name data_container --volume /www/public/uploads busybox true`.
  * `--name` parameter helps to identify the container by giving it a name. Otherwise it can be indentified by hexadecimal ID number.
  * `--volume` parameter creates a volume directory that can be shared with other containers.
  * `true` command is only to maintain the container.
* Container `data_container` provides the shared directory (called volume) at `/www/public/uploads` and other containers can use this volume by launching them with `--volumes-from data_container` parameter. For instance: `docker run --interactive --tty --rm --volumes-from data_container busybox`.
* The container will be visible via `docker ps --all` but not via `docker ps`.
* To terminate container type `docker rm data_container`.

#### Database container

* To launch database container run `docker run --name postgres_container --env POSTGRES_PASSWORD=lolopolo --detach postgres`.
  * `postgres` image is the official PostgreSQL image and will be downloaded before first launch.
  * `--name` parameter helps to identify the container by giving it a name. Otherwise it can be indentified by hexadecimal ID number.
  * `--env` parameter sets environment variable inside container. In this instance `POSTGRES_PASSWORD` sets the postgres password.
  * `--detach` parameter runs container in background.
  * It is recommended to use some randomly generated password, like using `env LC_CTYPE=C tr -dc "a-zA-Z0-9-_" < /dev/urandom | head -c 20`.
* The container sets the postgres database service.
* Other containers can use the `postgres_container`'s database by launching them with `--link postgres_container:postgres` parameter. For instance: `docker run --interactive --tty --rm postgres_container:postgres postgres /bin/bash`.
  * The access to the database can be established using environment variables that are automaticaly set by `--link` option. See `docker run --interactive --tty --rm --link postgres_container:postgres postgres env`.
* The container will be visible via `docker ps --all` but not via `docker ps`.
* To terminate container type `docker rm --force postgres_container`.

#### Application container

* All required configuration is stored in `Dockerfile` in environment variables.
* To build image type `docker build --tag placek/rack_on_docker .`.
  * `--tag` parameter helps to identify the image by giving it a name. Otherwise it can be indentified by hexadecimal ID number.
* To run image type `docker run --publish-all --link postgres_container:postgres --volumes-from data_container --name rack_on_docker_container --detach placek/rack_on_docker`.
  * `--name` parameter helps to identify the container by giving it a name. Otherwise it can be indentified by hexadecimal ID number.
  * `--publish-all` parameter is required to properly expose ports.
  * `--link` parameter makes an access to database from `postgres_container`.
  * `--volumes-from` parameter makes an access to volume from `data_container`.
  * `--detach` parameter runs container in background.
* To enter running container `docker exec --interactive --tty rack_on_docker_container /bin/bash`.
  * `--tty` parameter is required to allocate a pseudo-TTY for container.
  * `--interactive` parameter is required to make a STDIN connected to container.
  * `/bin/bash` is the command we want to execute on container.
* To terminate container type `docker kill rack_on_docker_container`.

#### Other

* Files in `.dockerignore` will not be added to docker image.
* Rake task `db:console` launches `irb` with access to database.
  * To run such console on already running container type `docker exec --interactive --tty rack_on_docker_container  bundle exec rake db:console`, or...
  * ...connect to database in separate container typing `docker run --tty --interactive  --link postgres_container:postgres --rm placek/rack_on_docker bundle exec rake db:console`.
* To run tests type `docker run --tty --interactive --env RACK_ENV=test --rm placek/rack_on_docker /bin/bash -c 'bundle exec rake db:schema:load && bundle exec rspec'`
  * `--tty` and `--interactive` params allow to display results and interrupt process with `^C` when needed.
  * `--env RACK_ENV=test` sets the environment variable (needed, for instance, to choose the database configuration).
  * `--rm` removes container after it's done.
* Environment variables:
  * `<NAME>_DIRECTORY` - directories used by application
  * `NGINX_PID_FILE` - path to the file where the pid of nginx server process is stored
  * `NGINX_WORKER_PROCESSES` - number of workers for nginx server
  * `NGINX_WORKER_CONNECTIONS` - maximum number of connections to nginx server
  * `NGINX_ACCESS_LOG_FILE` - log file path - nginx access log
  * `NGINX_ERROR_LOG_FILE` - log file path - nginx error log
  * `NGINX_LISTEN_PORT` - port that container is exposing
  * `UNICORN_PID_FILE` - path to the file where the pid of unicorn server process is stored
  * `UNICORN_SOCKET_FILE` - path to the unix socket of unicorn server
  * `UNICORN_WORKER_PROCESSES` - number of workers for unicorn server
  * `UNICORN_TIMEOUT` - unicorn server timeout
  * `UNICORN_STDOUT_LOG_FILE` - log file path - unicorn stdout
  * `UNICORN_STDERR_LOG_FILE` - log file path - unicorn stderr
  * `DATA_VOLUME` - volume directory shared by the _data-only_ container
  * `RACK_ENV` - environment for rack server
  * `POSTGRES_DATABASE_NAME` - name of database for application to connect to (or create if needed).
  * `POSTGRES_DATABASE_USER` - name of database user - for official postgres image it's just `postgres`.
  * `RUBY_MAJOR` - major version of ruby implementation, used to specify an URL to package, e.g. `2.3` in `https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.0.tar.gz`
  * `RUBY_VERSION` - minor version of ruby implementation, used to specify an URL to package, e.g. `2.3.0` in `https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.0.tar.gz`

### Web application address

To enter the web application via browser you need to get IP and port of the application.

#### IP

To get the IP address that app is running on type `docker-machine ip $DOCKER_MACHINE_NAME`:

```
$ docker-machine ip $DOCKER_MACHINE_NAME
196.168.99.100
```

#### Port

Use `docker port rack_on_docker_container` to get port:

```
$ docker port rack_on_docker_container
0.0.0.0:32769->80/tcp
```

The expression `0.0.0.0:32769->80/tcp` sais that app is running on port `32769`.

### TODO

* howto: switch containers after making a new build
