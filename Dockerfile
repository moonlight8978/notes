FROM ruby:2.6.4-alpine3.10

RUN apk add --no-cache --update \
  build-base \
  linux-headers \
  mysql-dev \
  nodejs \
  yarn \
  tzdata

ENV APP_PATH /usr/src/app
WORKDIR $APP_PATH

RUN gem install rails
COPY Gemfile* ./
RUN bundle install

EXPOSE 3000
