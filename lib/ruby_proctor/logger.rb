
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
    @file_path = './' + QUIZ_FILE_NAME
    @real_uid = Process.uid
    @effective_uid = Process.euid

    if (Process::UID.sid_available?)
      @saved_uid = `ps -p #{Process.pid} -o svuid=`.strip
    else
      @saved_uid = ''
    end

    puts @saved_uid
    puts @real_uid
    puts @effective_uid
  end

  def write_to_log(exam)
    exam.results.uid = @real_uid

    open(@file_path, 'a+') { |f|
      f.puts exam.results.to_hash.to_yaml
    }
  end

  def read_from_log
    quiz_attempts = Array.new
    YAML.load_stream(File.read(@file_path)) do |document|
      puts document
      if document.key?("uid") && document["uid"] == @real_uid
        quiz_attempts.push(OpenStruct.new(document))
      end
    end
    quiz_attempts 
  end


  def print_quiz_attempts(quiz_attempts)

    quiz_num = 1;

    for attempt in quiz_attempts do

      puts "| Quiz # " + quiz_num.to_s + "|"
      puts '---------------------------'

      puts 'Number of Questions Answered Correctly: ' + attempt.num_correct.to_s + ' / ' + attempt.total_questions.to_s
      puts 'Grade (Percentage): ' + attempt.grade.to_s
      puts 'Letter Grade: ' + attempt.letter_grade
      puts 'Time Completed: ' + attempt.time_completed

      if (attempt.time_elapsed && attempt.time_left)
        puts 'Time Elapsed: ' + attempt.time_elapsed
        puts 'Time Left: ' + attempt.time_left
        puts ""
      end
      puts '---------------------------'
      quiz_num += 1
    end
  end
end