FROM ruby:3.0.2

SHELL ["/bin/bash", "-c"]

RUN apt-get update -qq && apt-get install -y postgresql-client

ENV PORT=3000
ENV USER="user"

WORKDIR /home/$USER


RUN gem install bundler

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

EXPOSE $PORT

CMD ["rails", "server", "-b", "'0.0.0.0'"]