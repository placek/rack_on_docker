### Description

This is an example on how one can run rake web server in docker container.

### Tips

* Changing `Dockerfile` at `ENV RUBY_MAJOR 2.3` and `ENV RUBY_VERSION 2.3.0` will affect used ruby version.
* Changing `Dockerfile` at `ENV APP_PORT 3000` will not affect application.
* Bind `0.0.0.0` address at `CMD bundle exec ruby config.ru -p "$APP_PORT" -o 0.0.0.0` in `Dockerfile` is important to run web application!
* Files in `.dockerignore` will not be added to docker image.
* To build image type `docker build -t placek/rake_on_docker`.
* To run image type `docker run -tP placek/rake_on_docker`.

### Web application address

To enter the web application via browser you need to get port that is bind to application.
Use `docker ps` to get port:

```
$ docker ps
CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS              PORTS                     NAMES
c8598bb2b978        placek/rack_on_docker   "/bin/sh -c 'bundle e"   5 minutes ago       Up 5 minutes        0.0.0.0:32769->3000/tcp   compassionate_leakey
```

The expression `0.0.0.0:32769->3000/tcp` sais that app is running on port `32769`.


To get the IP address that app is running on type `docker-machine ip $DOCKER_MACHINE_NAME`:

```
$ docker-machine ip $DOCKER_MACHINE_NAME
196.168.99.100
```

The applicaion runs at [http://192.168.99.100:32769](http://192.168.99.100:32769).
