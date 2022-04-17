require 'rubygems'
require 'bundler/setup'

require 'os'

def ruby_proctor
  if OS.posix?
    require 'ruby_proctor/interfaces/terminal'
    ruby_proctor_terminal()
  elsif OS.windows?
    require 'ruby_proctor/interfaces/gui'
    ruby_proctor_gui()
  end
end