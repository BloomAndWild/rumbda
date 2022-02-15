FROM ruby:2.7 as builder

WORKDIR /rumbda 

COPY . /rumbda

RUN bundle install && gem build -o /rumbda/rumbda.gem rumbda.gemspec && gem install /rumbda/rumbda.gem && rm -rf /rumbda

ENTRYPOINT [ "rumbda" ]