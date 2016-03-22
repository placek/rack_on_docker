FROM centos:latest

MAINTAINER placzynski.pawel@gmail.com

ENV RUBY_MAJOR 2.3
ENV RUBY_VERSION 2.3.0

RUN yum -y update && yum -y install patch gcc-c++ make bzip2 autoconf automake libtool bison iconv-devel readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel \
    && yum clean all \
    && mkdir -p /usr/src/ruby \
    && curl -O "https://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.gz" \
    && tar -xf "ruby-$RUBY_VERSION.tar.gz" -C /usr/src/ruby --strip-components=1 \
    && cd /usr/src/ruby \
    && ./configure --disable-install-doc \
    && make \
    && make install \
    && rm -r /usr/src/ruby

RUN mkdir -p /www
WORKDIR /www

RUN gem install bundler
RUN echo "gem: --no-rdoc --no-ri" >> ".gemrc"

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 20 --retry 5
