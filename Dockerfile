FROM ruby:2.6

WORKDIR /app

COPY . /app

RUN gem install bundler && \
	bundle install

EXPOSE 9292

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "9292"]
