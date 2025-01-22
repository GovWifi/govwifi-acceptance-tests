FROM ruby:3.3.6-alpine

WORKDIR /usr/src/app

RUN apk --no-cache add \
      wpa_supplicant openssl \
      ruby ruby-rdoc ruby-bundler ruby-ffi mariadb-connector-c-dev \
      ruby-dev make gcc libc-dev aws-cli

COPY Gemfile Gemfile.lock .ruby-version ./

RUN bundle install
RUN mkdir certs

COPY . .

ENTRYPOINT "./run.sh"
