SET "PATH=%PATH%;C:\Ruby30-x64\bin"
ridk install 1 & gem install bundler -v 2.2.32 & gem install tk & gem install os & bundler install & gem build & gem install --local .\ruby_proctor-1.0.0.gem