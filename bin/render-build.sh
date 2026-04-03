#!/usr/bin/env bash

set -o errexit
set -o xtrace

bundle install
bundle exec rails assets:precompile
bundle exec rails db:migrate
bundle exec rake import:logs
