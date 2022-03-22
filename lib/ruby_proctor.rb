require 'rubygems'
require 'bundler/setup'

require 'os'

require 'ruby_proctor/interfaces/terminal'
require 'ruby_proctor/interfaces/gui'

def ruby_proctor
  if OS.posix?
    ruby_proctor_terminal()
  elsif OS.windows?
    ruby_proctor_gui()
  end
end