
require 'ruby_proctor/constants'
require 'ruby_proctor/question'
require 'ruby_proctor/exam'
require 'ruby_proctor/string_ext'
require 'yaml'

include Process::UID
include Constants

class Logger
  #YAML.load_stream(File.read('test.yml'))
  class LoggingError < StandardError
    def initialize(msg="Error Occurred During Logging")
      super
    end
  end

  def initialize()
    @file_path = ''
    @file_name = '.quizlog'
    @real_uid = Process.uid
    @effective_uid = Process.euid

    if (Process.sid_available?)
      @saved_uid = `ps -o pid,suid`[/(?<=^#{Process.pid}\s)\s*\d+/].strip
    else
      @saved_uid = ''
    end

    puts @saved_uid
    puts @real_uid
    puts @effective_uid
  end

  def write_to_log(exam)
    exam.results

    open(@file_path + @file_name, 'a') { |f|
      f.puts exam.to_hash.to_yaml
    }
  end
end