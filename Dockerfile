FROM centos:latest
MAINTAINER Paweł Placzyński <placzynski.pawel@gmail.com>

ENV APP_DIRECTORY /www
ENV APP_LOGS_DIRECTORY $APP_DIRECTORY/log
ENV APP_PIDS_DIRECTORY $APP_DIRECTORY/tmp/pids
ENV APP_SOCKETS_DIRECTORY $APP_DIRECTORY/tmp/sockets
ENV DATA_VOLUME /data

ENV NGINX_PID_FILE $APP_PIDS_DIRECTORY/nginx.pid
ENV UNICORN_PID_FILE $APP_PIDS_DIRECTORY/unicorn.pid

ENV NGINX_ACCESS_LOG_FILE $APP_LOGS_DIRECTORY/nginx.access.log
ENV NGINX_ERROR_LOG_FILE $APP_LOGS_DIRECTORY/nginx.error.log
ENV UNICORN_STDOUT_LOG_FILE $APP_LOGS_DIRECTORY/unicorn.stdout.log
ENV UNICORN_STDERR_LOG_FILE $APP_LOGS_DIRECTORY/unicorn.stderr.log

ENV UNICORN_SOCKET_FILE $APP_SOCKETS_DIRECTORY/unicorn.sock

ENV DATABASE_FILE $DATA_VOLUME/db.sqlite3

ENV NGINX_WORKER_PROCESSES 1
ENV UNICORN_WORKER_PROCESSES 5
ENV NGINX_WORKER_CONNECTIONS 1024
ENV NGINX_LISTEN_PORT 80
ENV UNICORN_TIMEOUT 30
ENV RACK_ENV development

ENV RUBY_MAJOR 2.3
ENV RUBY_VERSION 2.3.0

RUN echo -e "[nginx]\nname=nginx repository\nbaseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/\ngpgcheck=0\nenabled=1\n" > /etc/yum.repos.d/nginx.repo \
    && yum -y update \
    && yum -y install patch gcc-c++ make bzip2 autoconf automake libtool bison iconv-devel readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel sqlite-devel nginx \
    && yum clean all \
    && mkdir -p /usr/src/ruby \
    && curl -O "https://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.gz" \
    && tar -xf "ruby-$RUBY_VERSION.tar.gz" -C /usr/src/ruby --strip-components=1 \
    && cd /usr/src/ruby \
    && ./configure --disable-install-doc \
    && make \
    && make install \
    && rm -r /usr/src/ruby \
    && rm -rf /etc/nginx/*

COPY config/nginx.conf.erb /etc/nginx/
RUN ruby -rerb -e "puts ERB.new(File.read('/etc/nginx/nginx.conf.erb')).result" > /etc/nginx/nginx.conf \
    && rm /etc/nginx/nginx.conf.erb

RUN mkdir -p $APP_DIRECTORY $APP_LOGS_DIRECTORY $APP_PIDS_DIRECTORY $APP_SOCKETS_DIRECTORY
WORKDIR $APP_DIRECTORY

COPY Gemfile Gemfile.lock ./
RUN gem install bundler \
    && echo "gem: --no-rdoc --no-ri" >> ".gemrc" \
    && bundle install --jobs 20 --retry 5

COPY . ./

EXPOSE $NGINX_LISTEN_PORT
CMD bundle exec rake db:create db:migrate \
    && bundle exec unicorn --config-file config/unicorn.rb --env $RACK_ENV --daemonize \
    && nginx -g 'daemon off;'
