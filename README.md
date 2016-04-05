# Rack on Docker

### Description

This is an example on how one can run rack web server with sqlite3 database on unicorn via nginx in docker container.

### Usage/Tips

#### TL;DR
* To build images type:
  * `docker build --tag placek/data ./data`
  * `docker build --tag placek/rack_on_docker .`
* To run `data` container type:
  * `docker run --name data_container placek/data`
* To run `rack_on_docker` container type:
  * `docker run --publish-all --volumes-from data_container --name rack_on_docker_container --detach placek/rack_on_docker`
* To access `rack_on_docker` container type:
  * `docker run --interactive --tty --rm --volumes-from data_container placek/rack_on_docker /bin/bash` (to access it from separate container - recommended)
  * `docker exec --interactive --tty rack_on_docker_container /bin/bash` (to access running `rack_on_docker` container directly)
* To terminate containers type:
  * `docker kill rack_on_docker_container`
  * `docker rm data_container` (warning - it will remove the database)

#### Data-only container

* To build image run `docker build --tag placek/data ./data`.
  * `--tag` parameter helps to identify the image by giving it a name. Otherwise it can be indentified by hexadecimal ID number.
* To launch data-only container run `docker run --name data_container placek/data`.
  * `--name` parameter helps to identify the container by giving it a name. Otherwise it can be indentified by hexadecimal ID number.
* The container shares the `/data` directory between other containers.
* Other containers can use the `data_container`'s volume (i.e. `/data` directory) by launching them with `--volumes-from` parameter. For instance: `docker run --interactive --tty --rm --volumes-from data_container busybox` have access to `/data` directory.
* The container will be visible via `docker ps --all` but not via `docker ps`.
* To terminate container type `docker rm data_container`.

#### Application container

* All required configuration is stored in `Dockerfile` in environment variables.
* To build image type `docker build --tag placek/rack_on_docker .`.
  * `--tag` parameter helps to identify the image by giving it a name. Otherwise it can be indentified by hexadecimal ID number.
* To run image type `docker run --publish-all --volumes-from data_container --name rack_on_docker_container placek/rack_on_docker`.
  * `--name` parameter helps to identify the container by giving it a name. Otherwise it can be indentified by hexadecimal ID number.
  * `--publish-all` parameter is required to properly expose ports.
  * `--volumes-from` parameter makes an access to `/data` directory (volume) from `data_container`.
* To enter running container `docker exec --interactive --tty --volumes-from data_container rack_on_docker_container /bin/bash`.
  * `--tty` parameter is required to allocate a pseudo-TTY for container.
  * `--interactive` parameter is required to make a STDIN connected to container.
  * `--volumes-from` parameter makes an access to `/data` directory (volume) from `data_container`.
  * `/bin/bash` is the command we want to execute on container.
* To terminate container type `docker kill rack_on_docker_container`.

#### Other

* Files in `.dockerignore` will not be added to docker image.
* Rake task `db:console` launches `irb` with access to database.
  * To run such console on already running container type `docker exec --interactive --tty rack_on_docker_container bundle exec rake db:console`, or...
  * ...connect to database in separate container typing `docker run --tty --interactive --rm placek/rack_on_docker bundle exec rake db:console`.
* Environment variables:
  * `APP_DIRECTORY` - directory with application source code
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
  * `DATABASE_FILE` - path to sqlite3 database
  * `RACK_ENV` - environment for rack server
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

* howto: run tests using docker
* change: remove sqlite3 with postgresql
* howto: switch containers after making a new build
