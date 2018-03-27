FROM ruby:2.5

RUN apt-get update -qq && \
    apt-get install -y nodejs \
    build-essential \
    libpq-dev \
    postgresql-client \
    fonts-ipafont-gothic \
    fonts-ipafont-mincho \
    graphviz \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

RUN gem install bundler rails
RUN mkdir /app
WORKDIR /app