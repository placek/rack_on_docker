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

RUN echo 'gem: --no-rdoc --no-ri' >> "$HOME/.gemrc"

ENV GEM_HOME /usr/local/bundle
ENV PATH $GEM_HOME/bin:$PATH
RUN gem install bundler \
  && bundle config --global path "$GEM_HOME" \
  && bundle config --global bin "$GEM_HOME/bin"

ENV BUNDLE_APP_CONFIG $GEM_HOME
