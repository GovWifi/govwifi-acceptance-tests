FROM ruby:3.4.9-alpine3.22

WORKDIR /usr/src/app

RUN apk --no-cache add \
      wpa_supplicant openssl \
      ruby ruby-rdoc ruby-bundler ruby-ffi mariadb-connector-c-dev \
      ruby-dev make gcc libc-dev aws-cli git

COPY Gemfile Gemfile.lock .ruby-version ./

RUN bundle config set with 'test' && bundle install
RUN mkdir certs

COPY . .
RUN bundle install

ENTRYPOINT "./run.sh"
