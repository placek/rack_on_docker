## USE centos:latest IMAGE AS BASE
FROM centos:latest
MAINTAINER Paweł Placzyński <placzynski.pawel@gmail.com>


## INSTALL RUBY
# set ruby version
ENV RUBY_MAJOR 2.3
ENV RUBY_VERSION 2.3.0
# get dependencies
RUN yum -y update \
    && yum -y install patch gcc-c++ make bzip2 autoconf automake libtool bison iconv-devel readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel \
# clean yum cache
    && yum clean all \
# download and extract ruby tarball
    && mkdir -p /usr/src/ruby \
    && curl -O "https://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.gz" \
    && tar -xf "ruby-$RUBY_VERSION.tar.gz" -C /usr/src/ruby --strip-components=1 \
    && cd /usr/src/ruby \
# configure, compile and install ruby
    && ./configure --disable-install-doc \
    && make \
    && make install \
# clean up
    && rm -r /usr/src/ruby


## CREATE ENVIRONMENT
RUN mkdir -p /www/{log,tmp/{pids,sockets}}
WORKDIR /www


## INSTALL GEMS
# install bundler
RUN gem install bundler
# don't generate documentation
RUN echo "gem: --no-rdoc --no-ri" >> ".gemrc"
# get gemfile
COPY Gemfile Gemfile.lock ./
# install gems
RUN bundle install --jobs 20 --retry 5


## INSTALL NGINX
# add yum repo configuration for nginx
ADD nginx.repo /etc/yum.repos.d/nginx.repo
# install nginx
RUN yum -y update \
    && yum -y install nginx \
    && yum clean all \
# remove nginx configuration...
    && rm -rf /etc/nginx/*
# ...and replace it with our configuration
COPY nginx.conf /etc/nginx


## COPY PROJECT TO TARGET DOCKER IMAGE
COPY . ./


## LAUNCH APPLICATION
# set rack environment (can be replaced with RAILS_ENV)
ENV RACK_ENV development
# expose port
EXPOSE 80
# run server
CMD bundle exec unicorn --config-file unicorn.rb --env "$RACK_ENV" --daemonize \
    && nginx -g 'daemon off;'
