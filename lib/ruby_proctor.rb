$LOAD_PATH.unshift File.dirname($0)

require 'rubygems'
require 'bundler/setup' # IS unable to find os-1.1.4 on OCRA windows, lots of chicken/egg problems.

require 'os'

if OS.posix?
  require 'ruby_proctor/interfaces/terminal.rb'
  ruby_proctor_terminal()
elsif OS.windows?
  require 'ruby_proctor/interfaces/gui.rb'
  ruby_proctor_gui()
end