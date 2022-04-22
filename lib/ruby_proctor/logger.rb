
require 'ruby_proctor/constants'
require 'ruby_proctor/question'
require 'ruby_proctor/exam'
require 'ruby_proctor/string_ext'
require 'ostruct'

require 'yaml'

require 'os'

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

    if OS.windows?
      @file_path = ENV['ALLUSERSPROFILE'] + "/Ruby Proctor/quizlog.dat"
    else
      @file_path = './' + QUIZ_FILE_NAME
    end
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
      #puts document
      if document.key?("uid") && document["uid"] == @real_uid
        quiz_attempts.push(OpenStruct.new(document))
      end
    end
    quiz_attempts 
  end


  def print_quiz_attempts(quiz_attempts)

    quiz_num = 1;

    for attempt in quiz_attempts do

      puts "| Quiz # " + quiz_num.to_s + " |"
      puts "---------------------------"

      puts 'Number of Questions Answered Correctly: ' + attempt.num_correct.to_s + ' / ' + attempt.total_questions.to_s
      puts 'Grade (Percentage): ' + attempt.grade.to_s
      puts 'Letter Grade: ' + attempt.letter_grade
      
      if (attempt.quiz_name)
        puts 'Quiz Name: ' + attempt.quiz_name
      end
      puts 'Time Started: ' + attempt.time_started
      puts 'Time Completed: ' + attempt.time_completed
      puts 'Time Elapsed: ' + attempt.time_elapsed

      if (attempt.time_elapsed && attempt.time_left)
        puts 'Time Left: ' + attempt.time_left
        puts ""
      end
      puts ""
      #puts "---------------------------\n\n\n"
      quiz_num += 1
    end
  end
end