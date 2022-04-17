#!/bin/sh
gem build ruby_proctor.gemspec
gem install --local ruby_proctor-1.0.0.gem
cd ..
ruby_proctor "$@"
cd ruby-proctor 