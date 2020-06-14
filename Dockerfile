FROM ruby:2.7-slim AS zk-ruby

WORKDIR /root/workdir

RUN apt-get update -qq

RUN gem update --system
COPY Gemfile .
RUN bundle

ENTRYPOINT [ "ruby" ]
