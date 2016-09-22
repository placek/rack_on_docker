# Rack on Docker

### Description

This is an example on how one can run rack web server with postgres database and volume sharing on unicorn using docker-composer.

### Usage/Tips

#### TL;DR
* To build images type:
  * `docker-compose build`
* To start composition type:
  * `docker-compose up`
* To run migrations (or any other rake task) type:
  * `docker-compose exec web bundle exec rake db:migrate`
* To terminate composition type:
  * `docker-compose down` (warning - it will remove the database)
* To run tests type:
  * `docker-compose run -e RACK_ENV=test --rm web /bin/bash -c 'bundle exec rake db:schema:load && bundle exec rspec'`

#### Other

* Files in `.dockerignore` will not be added to docker image.
* Rake task `console` launches `irb` with access to database.
  * To run such console on already running container type `docker-compose exec web bundle exec rake console`, or...
  * ...connect to database in separate container typing `docker run --rm web bundle exec rake console`.
* Environment variables:
  * `<NAME>_DIRECTORY` - directories used by application
  * `UNICORN_PID_FILE` - path to the file where the pid of unicorn server process is stored
  * `UNICORN_SOCKET_FILE` - path to the unix socket of unicorn server
  * `UNICORN_WORKER_PROCESSES` - number of workers for unicorn server
  * `UNICORN_TIMEOUT` - unicorn server timeout
  * `UNICORN_STDOUT_LOG_FILE` - log file path - unicorn stdout
  * `UNICORN_STDERR_LOG_FILE` - log file path - unicorn stderr
  * `RACK_ENV` - environment for rack server

### TODO

* howto: switch containers after making a new build
