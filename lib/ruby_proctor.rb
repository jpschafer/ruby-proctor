# main.rb
#

# Include Dir for OCRA
$:.unshift File.dirname($0)

# includes
require 'rubygems'

require 'ruby_proctor/constants.rb'
require 'ruby_proctor/exam.rb'
require 'ruby_proctor/question.rb'
require 'ruby_proctor/processor.rb'
require 'ruby_proctor/proctor.rb'
require 'ruby_proctor/string_ext.rb'

include Constants

def ruby_proctor

  # Print Pretty ASCII Logo
  puts ''
  puts '##################################################################'
  puts '##  ______      _          ______               _               ##'
  puts '##  | ___ \    | |         | ___ \             | |              ##'
  puts '##  | |_/ /   _| |__  _   _| |_/ / __ ___   ___| |_ ___  _ __   ##'
  puts "##  |    / | | | '_ \\| | | |  __/ '__/ _ \\ / __| __/ _ \\| '__|  ##"
  puts '##  | |\ \ |_| | |_) | |_| | |  | | | (_) | (__| || (_) | |     ##'
  puts '##  \_| \_\__,_|_.__/ \__, \_|  |_|  \___/ \___|\__\___/|_|     ##'
  puts '##                     __/ |                                    ##'
  puts '##                    |___/                                     ##'
  puts '##################################################################'
  puts ''

  # Check that only a filename is passed
  if ARGV.length < 1
    puts "Too few arguments, arguments are as follows: rubyProctor.exe <file_path> <num_questions> <time_in_minutes> "
    puts "Exiting..."
    exit
  elsif ARGV.length > 3
    puts "Too many arguments, arguments are as follows: rubyProctor.exe <file_path> <num_questions> <time_in_minutes> "
    puts "Exiting..."
    exit
  end

  filepath = ARGV[0]
  max_questions = -1

  if ARGV[1]
    if ARGV[1].is_integer?
      if ARGV[1].to_i <= 0 || ARGV[1].to_i > Constants::EXAM_MAX_QUESTIONS
        puts "Can't pick zero, a negative number, or above 10000 questions for an exam, please pick a number above 0, but less than 10000 (Max supported questions)"
        puts "NOTE: anything above the number of total questions in the exam will return the entire question set and no more"
        puts "Exiting..."
        exit
      end
      max_questions = ARGV[1].to_i
    else
      puts "Number of Questions Specified must be a number greater than 0"
      puts "NOTE: anything above the number of total questions in the exam will return the entire question set and no more"
      puts "Exiting..."
      exit
    end
  end

  time = -1
  if ARGV[2]
    if ARGV[2].is_integer?
      if ARGV[2].to_i <= 0
        puts "Can't pick zero or negative number of minutes, please pick a number above 0"
        puts "NOTE: input nothing for the last argument if you want an unlimited time test"
        puts "Exiting..."
        exit
      end
      time = ARGV[2].to_i
    else
      puts "Number of minutes must be a number greater than 0"
      puts "NOTE: input nothing for the last argument if you want an unlimited time test"
      puts "Exiting..."
      exit
    end
  end

  if(!File.exist?(filepath))
    puts 'Questions File not found, exiting..'
    exit
  end

  #puts "Welcome to Ruby Proctor!\n"

  puts "Beginning to Process Exam ...\n\n"
  processor = Processor.new(filepath, max_questions)

  # Try to Process, and cleanly display any exceptions
  begin
    exam = processor.process()
    puts "Exam Processed Successfully"
  rescue => e
    puts "** Error Processing Exam File: " + e.message + " **"
    puts "Try Resolving the above error, and try running again\n\n"
    puts "Exiting..."
    exit # Exit Program, we can't use this Exam File
  end

  # Start Officiating Exam
  proctor = Proctor.new(exam, time)
  proctor.officiate_exam

  puts 'Exiting...'
end