@ECHO OFF
REM Make sure you have ocra installed via gem 'install ocra' and gem install tty-spinner
ocra main.rb --output rubyProctor.exe --console --dll ruby_builtin_dlls\libssp-0.dll --dll ruby_builtin_dlls\libgmp-10.dll --dll ruby_builtin_dlls\libgcc_s_seh-1.dll --dll ruby_builtin_dlls\libwinpthread-1.dll