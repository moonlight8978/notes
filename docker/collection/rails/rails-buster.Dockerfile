FROM ruby:2.7.2-buster as base

# Already shipped with base image: default-libmysqlclient-dev, libpq-dev, imagemagick
RUN apt-get update -qq && \
  apt-get install -y \
  build-essential

WORKDIR /app

EXPOSE 3000

# -----
# Development usage
# -----
FROM base as development

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt-get update -qq && \
  apt-get install -y \
  nodejs \
  yarn \
  # Text editor for credentials edit
  vim

RUN gem install rails -v 6.1.0
COPY Gemfile* ./
RUN bundle config set without 'staging production' && \
  bundle install

CMD ["rails", "s", "-b", "0.0.0.0"]

EXPOSE 3035

# ----
# Production usage
# ----

FROM base as production-base

COPY Gemfile* ./
RUN bundle config set without 'test development' && \
  bundle install

FROM production-base as assets-builder

ARG RAILS_MASTER_KEY
ARG RAILS_ENV

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt-get update -qq && \
  apt-get install -y \
  nodejs \
  yarn

COPY . .
RUN RAILS_ENV=${RAILS_ENV} RAILS_MASTER_KEY=${RAILS_MASTER_KEY} rails assets:precompile

FROM production-base as production

COPY . .
COPY --from=assets-builder /app/public /app/public

RUN mkdir -p tmp/pids tmp/sockets

CMD ["bundle", "exec", "puma"]
