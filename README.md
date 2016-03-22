### Description

This is an example on how one can run rake web server in docker container.

### Tips

* Changing `Dockerfile` at `ENV RUBY_MAJOR 2.3` and `ENV RUBY_VERSION 2.3.0` will affect used ruby version.
* Changing `Dockerfile` at `ENV APP_PORT 3000` will not affect application.
* Bind `0.0.0.0` address at `CMD ["bundle", "exec", "ruby", "config.ru", "-p", "3000", "-o", "0.0.0.0"]` in `Dockerfile` is important to run web application!
* Files in `.dockerignore` will not be added to docker image.
* To build image type `docker build -t placek/rake_on_docker`.
* To run image type `docker run -tP placek/rake_on_docker`.
* To get port that is bind to application type `docker ps`.
* To get the IP address that app is running on type `docker-machine ip $DOCKER_MACHINE_NAME`
