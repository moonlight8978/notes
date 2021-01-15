FROM ruby:2.7.2-alpine3.12 as base

RUN apk --update add \
  build-base \
  tzdata \
  nodejs \
  # for Postgres users
  postgresql-dev \
  # for MySQL users
  mysql-dev \
  # for image processing
  imagemagick

WORKDIR /app

EXPOSE 3000

# -----
# Development usage
# -----
FROM base as development

RUN apk add \
  nodejs \
  yarn \
  # dev purpose (edit credentials, or debugging)
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

RUN apk add \
  nodejs \
  yarn

COPY . .
RUN RAILS_ENV=${RAILS_ENV} RAILS_MASTER_KEY=${RAILS_MASTER_KEY} rails assets:precompile

FROM production-base as production

COPY . .

# Temp folders should not be included to production image
RUN mkdir -p tmp/pids tmp/sockets log storage

CMD ["bundle", "exec", "puma"]

FROM nginx:1.19.6-alpine

WORKDIR /app

COPY conf.d /etc/nginx/conf.d

COPY --from=assets-builder /app/public /app

CMD ["nginx", "-g", "daemon off;"]
