FROM ruby:2.5

RUN apt-get update -qq && \
    apt-get install -y nodejs \
    build-essential \
    libpq-dev \
    postgresql-client \
    fonts-ipafont-gothic \
    fonts-ipafont-mincho \
    libfontconfig \
    openjdk-8-jre \
    openjdk-8-jre-headless \
    openjdk-8-jdk \
    openjdk-8-jdk-headless \
    graphviz \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

RUN curl --silent --show-error --location --fail --retry 3 --output /tmp/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_64.0.3282.186-1_amd64.deb \
      && (sudo dpkg -i /tmp/google-chrome-stable_current_amd64.deb || sudo apt-get -fy install)  \
      && rm -rf /tmp/google-chrome-stable_current_amd64.deb \
      && sudo sed -i 's|HERE/chrome"|HERE/chrome" --disable-setuid-sandbox --no-sandbox|g' \
           "/opt/google/chrome/google-chrome" \
      && google-chrome --version

RUN export CHROMEDRIVER_RELEASE=$(curl --location --fail --retry 3 http://chromedriver.storage.googleapis.com/LATEST_RELEASE) \
      && curl --silent --show-error --location --fail --retry 3 --output /tmp/chromedriver_linux64.zip "http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_RELEASE/chromedriver_linux64.zip" \
      && cd /tmp \
      && unzip chromedriver_linux64.zip \
      && rm -rf chromedriver_linux64.zip \
      && sudo mv chromedriver /usr/local/bin/chromedriver \
      && sudo chmod +x /usr/local/bin/chromedriver \
      && chromedriver --version

# start xvfb automatically to avoid needing to express in circle.yml
ENV DISPLAY :99
RUN printf '#!/bin/sh\nXvfb :99 -screen 0 1280x1024x24 &\nexec "$@"\n' > /tmp/entrypoint \
  && chmod +x /tmp/entrypoint \
        && sudo mv /tmp/entrypoint /docker-entrypoint.sh

RUN gem install bundler rails
RUN mkdir /app
WORKDIR /app

CMD [ "irb" ]