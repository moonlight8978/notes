FROM fluent/fluentd:v1.6.2-1.0

USER root

RUN fluent-gem install fluent-plugin-elasticsearch --no-document
RUN fluent-gem install fluent-plugin-multi-format-parser --no-document

USER fluent
