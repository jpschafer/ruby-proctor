# main.rb
#

# Include Dir for OCRA
$:.unshift File.dirname($0)

# includes
require 'rubygems'
require 'bundler/setup'

require 'ostruct'

require 'ruby_proctor/constants.rb'
require 'ruby_proctor/exam.rb'
require 'ruby_proctor/question.rb'
require 'ruby_proctor/logger'
require 'ruby_proctor/processor.rb'
require 'ruby_proctor/proctor.rb'
require 'ruby_proctor/string_ext.rb'

include Constants

def ruby_proctor_terminal

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

  # Parse Options, POSIX Style
  require 'optparse'

  options = OpenStruct.new

  begin
    OptionParser.new do |opt|
      opt.on('-f [FILE_PATH]', 'File Path to Quiz (Can be relative or absolute)') { |o| options.file_path = o }
      opt.on('-q [NUM_QUESTIONS]', 'number of questions for quiz') { |o| options.num_questions = o }
      opt.on('-t [TIME_LIMIT]', 'Sets a time limit by number of minutes') { |o| options.time_limit = o }
      opt.on('-v', 'Provides a print out of all of your quiz attempts') { |o| options.view_quizzes = true }
    end.parse!
  rescue => e
    puts "** Error Parsing Arguments: " + e.message + " **"
    puts "Try Resolving the above error, and try running again\n\n"
    puts "Exiting..."
    exit # Exit Program, we can't use this Exam File
  end

  options_hash = options.to_h()

  if options.view_quizzes && options_hash.length == 1
    # Delegate Printing out All Quizzes for current PID
    logger = Logger.new
    quiz_attempts = logger.read_from_log
    logger.print_quiz_attempts(quiz_attempts)
    puts "Exiting..."
    exit
  elsif options.view_quizzes && options_hash.length > 1
    puts "Invalid Arguments: No other Arguments can be used with -v for viewing the quizzes"
    puts "Exiting..."
    exit 
  elsif options_hash.length == 0
    puts "Not enough arguments to perform any action, run 'ruby_proctor -h' to get a list of available arguments and their function"
    puts "Exiting..."
    exit 
  elsif !options.file_path
    puts "No File name was specified with quiz configuration! Make sure you provide a filepath with the -f argument"
    puts "Exiting..."
    exit 
  end
  # # Check that only a filename is passed
  # if ARGV.length < 1
  #   puts "Too few arguments, arguments are as follows: ruby_proctor <file_path> <num_questions> <time_in_minutes> "
  #   puts "Exiting..."
  #   exit
  # elsif ARGV.length > 3
  #   puts "Too many arguments, arguments are as follows: ruby_proctor <file_path> <num_questions> <time_in_minutes> "
  #   puts "Exiting..."
  #   exit
  #end

  filepath = options.file_path
  max_questions = -1

  if options.num_questions
    if options.num_questions.is_integer?
      if options.num_questions.to_i <= 0 || options.num_questions.to_i > Constants::QUIZ_MAX_QUESTIONS
        puts "Can't pick zero, a negative number, or above 10000 questions for an exam, please pick a number above 0, but less than 10000 (Max supported questions)"
        puts "NOTE: anything above the number of total questions in the exam will return the entire question set and no more"
        puts "Exiting..."
        exit
      end
      max_questions = options.num_questions.to_i
    else
      puts "Number of Questions Specified must be a number greater than 0"
      puts "NOTE: anything above the number of total questions in the exam will return the entire question set and no more"
      puts "Exiting..."
      exit
    end
  end

  time = -1
  if options.time_limit
    if options.time_limit.is_integer?
      if options.time_limit.to_i <= 0
        puts "Error: Can't pick zero or negative number of minutes, please pick a number above 0"
        puts "NOTE: Omit the -t flag if you wish for an unlimited time test"
        puts "Exiting..."
        exit
      end
      time = options.time_limit.to_i
    else
      puts "Number of minutes must be a valid number greater than 0"
      puts "NOTE: Omit the -t flag if you wish for an unlimited time test"
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