FROM ruby:2.3.1
MAINTAINER Paweł Placzyński <placzynski.pawel@gmail.com>

ENV APP_DIRECTORY /www
ENV APP_LOGS_DIRECTORY $APP_DIRECTORY/log
ENV APP_PIDS_DIRECTORY $APP_DIRECTORY/tmp/pids
ENV APP_SOCKETS_DIRECTORY $APP_DIRECTORY/tmp/sockets

ENV UNICORN_PID_FILE $APP_PIDS_DIRECTORY/unicorn.pid
ENV UNICORN_STDOUT_LOG_FILE $APP_LOGS_DIRECTORY/unicorn.stdout.log
ENV UNICORN_STDERR_LOG_FILE $APP_LOGS_DIRECTORY/unicorn.stderr.log
ENV UNICORN_WORKER_PROCESSES 5
ENV UNICORN_TIMEOUT 30

ENV RACK_ENV production

RUN mkdir -p $APP_LOGS_DIRECTORY $APP_PIDS_DIRECTORY $APP_SOCKETS_DIRECTORY
WORKDIR $APP_DIRECTORY

COPY Gemfile Gemfile.lock ./
RUN echo "gem: --no-rdoc --no-ri" >> ".gemrc" && bundle install --jobs 20 --retry 5 --deployment

COPY . ./

CMD bundle exec unicorn --config-file config/unicorn.rb --env $RACK_ENV
