# gui.rb
#

# Include Dir for OCRA
# $:.unshift File.dirname($0)

# includes
require 'rubygems'
require 'bundler/setup'

require 'tk'

require 'ruby_proctor/constants.rb'
require 'ruby_proctor/exam.rb'
require 'ruby_proctor/question.rb'
require 'ruby_proctor/processor.rb'
require 'ruby_proctor/proctor.rb'
require 'ruby_proctor/string_ext.rb'

include Constants

def ruby_proctor_gui
  proctoring = TkVariable.new # Variable Used to Let Screen Behave Differently
  proctoring.value = false



  configuration()

  Tk.mainloop
end

def configuration()
  # File Dialogue
  root = TkRoot.new { title "Ruby Proctor - Configuration" }

  filepath = TkVariable.new
  number_questions = TkVariable.new
  time_limit = TkVariable.new

  file_entry = TkEntry.new(root) do
    pack("side" => "top",  "padx"=> "50", "pady"=> "50")
  end

  button = TkButton.new(root) do
    text "Open"
    pack("side" => "top",  "padx"=> "50", "pady"=> "50")
  end

  button.comman = Proc.new {
    l_value = Tk.getOpenFile
    if !l_value.empty?
      filepath.value = l_value
    end
  }

  file_entry.textvariable = filepath

  # Number of Questions
  number_questions_entry = TkEntry.new(root) do
    pack("side" => "left",  "padx"=> "50", "pady"=> "50")
  end

  number_questions_entry.textvariable = number_questions

  # Time Limit
  time_limit_entry = TkEntry.new(root) do
    pack("side" => "left",  "padx"=> "50", "pady"=> "50")
  end

  time_limit_entry.textvariable = time_limit

  # Load Quiz Button
  load_button = TkButton.new(root) do
    text "Load Quiz"
    pack("side" => "bottom",  "padx"=> "50", "pady"=> "50")
  end

  load_button.comman = Proc.new {
    proctor_window(filepath, number_questions, time_limit)
  }

  file_entry.textvariable = filepath

end

def proctor_window(filepath, number_questions, time_limit)
  proctor_top = TkToplevel.new { title "Ruby Proctor - Quiz" }
end