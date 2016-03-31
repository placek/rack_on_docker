# Rack on Docker

### Description

This is an example on how one can run rake web server with sqlite3 database on unicorn via nginx in docker container.

### Explanation/Usage/Tips

#### Data-only container

* To build image run `docker build --tag placek/data ./data`.
* To launch data-only container run `docker run --name data_container placek/data true`.
* Other containers can use the `data_container`'s volume by executing them with `--volumes-from` parameter, like `docker run --interactive --tty --rm --volumes-from data_container busybox`.
* The container will be visible via `docker ps --all` but not via `docker ps`.
* To terminate container type `docker rm data_container`.

#### Application container

* Changing `Dockerfile` at `ENV RUBY_MAJOR 2.3` and `ENV RUBY_VERSION 2.3.0` will affect used ruby version.
* Changing `Dockerfile` at `ENV DATABASE_PATH /data/db.sqlite3` will change a database file location.
  * The path is used at `database: <%=  ENV['DATABASE_PATH'] %>` in `config/database.yml`.
  * The `/data` directory is a volume from the _Data-only container_.
* Port number at `EXPOSE 80` in `Dockerfile` must match `listen 80;` in `nginx.conf`.
* To build image type `docker build --tag placek/rake_on_docker .`.
  * Parameter `--tag placek/rake_on_docker` is optional - it assigns the name to image so there is no need to know the ID of the image.
* To run image type `docker run --publish-all --name rake_on_docker_container placek/rake_on_docker`.
  * Parameter `--publish-all` is required to properly expose ports.
  * Parameter `--name rake_on_docker_container` is optional - it assigns the name to container so there is no need to know the ID of the container.
  * Name `placek/rake_on_docker` can be replaced with image ID.
* To enter running container `docker exec --interactive --tty rake_on_docker_container /bin/bash`.
  * Parameter `--tty` is required to allocate a pseudo-TTY for container.
  * Parameter `--interactive` is required to make a STDIN connected to container.
  * Name `rake_on_docker_container` can be replaced with container ID.
  * `/bin/bash` is the command we want to execute on container.
* To terminate container type `docker kill rake_on_docker_container`.

#### Other

* Files in `.dockerignore` will not be added to docker image.
* Rake task `db:console[environment]` launches `irb` with access to database.
  * To run such console type `docker run --tty --interactive --rm placek/rake_on_docker /bin/bash` to connect to database in separate container, or...
  * ...you can enter already running container `docker exec --interactive --tty rake_on_docker_container /bin/bash`.

### Web application address

To enter the web application via browser you need to get port that is bind to application.
Use `docker ps` to get port:

```
$ docker ps
CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS              PORTS                     NAMES
c8598bb2b978        placek/rack_on_docker   "/bin/sh -c 'bundle e"   5 minutes ago       Up 5 minutes        0.0.0.0:32769->3000/tcp   rake_on_docker_container
```

The expression `0.0.0.0:32769->3000/tcp` sais that app is running on port `32769`.


To get the IP address that app is running on type `docker-machine ip $DOCKER_MACHINE_NAME`:

```
$ docker-machine ip $DOCKER_MACHINE_NAME
196.168.99.100
```

It means that applicaion runs at [http://192.168.99.100:32769](http://192.168.99.100:32769).
