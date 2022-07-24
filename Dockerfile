FROM ruby:2.7.1
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
  apt-get update -qq && \
  apt-get install -y build-essential \
  nodejs \
  yarn \
  vim
COPY ./Gemfile* /app/
WORKDIR /app
RUN bundle install
COPY . /app
RUN yarn install --check-files
RUN node -v
CMD ["bin/rails", "s", "-b", "0.0.0.0"] 