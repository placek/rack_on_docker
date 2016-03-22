## USE centos:latest IMAGE AS BASE
FROM centos:latest
MAINTAINER Paweł Placzyński <placzynski.pawel@gmail.com>


## INSTALL RUBY
# set ruby version
ENV RUBY_MAJOR 2.3
ENV RUBY_VERSION 2.3.0
# get dependencies
RUN yum -y update && yum -y install patch gcc-c++ make bzip2 autoconf automake libtool bison iconv-devel readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel \
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
RUN mkdir -p /www
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


## COPY PROJECT TO TARGET DOCKER IMAGE
COPY . ./


## LAUNCH APPLICATION
# set internal port
ENV APP_PORT 3000
# expose port
EXPOSE "$APP_PORT"
# run server
CMD bundle exec ruby config.ru -p "$APP_PORT" -o 0.0.0.0
