require 'ruby_proctor/question'
require 'ruby_proctor/exam'
require 'ruby_proctor/string_ext'
require 'ruby_proctor/logger'

require 'timeout'

class Proctor

  attr_accessor :exam

  def initialize(exam, time)
    @exam = exam
    @time = time
    @logger = Logger.new
  end

  def officiate_exam
    start_time = Time.now

    puts "\n" + 'This is a ' + exam.questions.length.to_s + ' question exam'

    if (@time <= 0)
      puts "You have unlimited time to complete, good luck!"
    elsif (@time == 1)
      puts 'you have ' + @time.to_s + ' minute to complete, good luck!'
    else
      puts 'you have ' + @time.to_s + ' minutes to complete, good luck!'
    end
    puts 'Starting Exam....' + "\n\n"

    question_number = 1
    exam.questions.each do |question|
      puts "Question #" + question_number.to_s + ": \n"  + question.question

      answer_num = 1

      puts "\nChoices:"
      question.answers.each do |answer|
        puts answer_num.to_s + ' - ' + answer
        answer_num += 1
      end

      begin
        answer = get_answer(question.answers.length, start_time)
      rescue => e
        print e
        print "Time is Up!\n\n"
        break
      end
        puts ''

      question.selected_answer = answer
      question_number += 1
    end
    puts "Exam is Over!\n\n"

    print_exam_results(start_time)

      # Try to Process, and cleanly display any exceptions
  begin
    @logger.write_to_log(@exam)
  rescue => e
    puts "** Error Writing to Log File: " + e.message + " **"
  end

  end


  def print_exam_results(start_time)
    puts '################'
    puts '# Quiz Results #'
    puts '################'
    puts ''

    # Calculate Percentage
    grade = grade_exam(start_time)

    puts 'Number of Questions Answered Correctly: ' + @exam.results.num_correct.to_s + ' / ' + @exam.results.total_questions.to_s
    puts 'Grade (Percentage): ' + @exam.results.grade.to_s
    puts 'Letter Grade: ' + @exam.results.letter_grade
    puts 'Time Started: ' + @exam.results.time_started
    puts 'Time Completed: ' + @exam.results.time_completed
    puts 'Time Elapsed: ' + @exam.results.time_elapsed

    if (@time > 0)
      puts 'Time Left: ' + @exam.results.time_left
      puts ""
    end
  end

  def grade_exam(start_time)
    num_correct = 0
    grade = 0
    exam.questions.each do |question|
      if question.correct_answer.eql?(question.selected_answer)
        num_correct += 1
      end
    end

    # Calculate Percentage
    grade = (num_correct.to_f / exam.questions.length.to_f) * 100

    #puts 'Number of Questions Answered Correctly: ' + num_correct.to_s + ' / ' + exam.questions.length.to_s
    @exam.results.num_correct = num_correct
    @exam.results.total_questions = exam.questions.length
    @exam.results.grade = grade.to_s + '%'
    @exam.results.letter_grade = get_letter_grade(grade)
    @exam.results.time_started = start_time.strftime("%m/%d/%Y %I:%M %p")
    @exam.results.time_completed = Time.now.strftime("%m/%d/%Y %I:%M %p")

    time_elapsed = calc_time_elapsed(start_time).round

    time_elapsed_hours = time_elapsed / (60*60)
    time_elapsed_minutes = (time_elapsed / 60) % 60
    time_elapsed_seconds = time_elapsed % 60

    @exam.results.time_elapsed = time_elapsed_hours.to_s + ':' + time_elapsed_minutes.to_s + ':' + time_elapsed_seconds.to_s

    if (@time > 0)
      # Calculate Time Left
      time_left = calc_time_left(start_time).round

      time_left_hours = time_left / (60*60)
      time_left_minutes = (time_left / 60) % 60
      time_left_seconds = time_left % 60

      @exam.results.time_left =  time_left_hours.to_s + ':' + time_left_minutes.to_s + ':' + time_left_seconds.to_s
      puts ""
    end
    grade
  end

  def get_letter_grade(grade)
    letter_grade = 'F'
    if grade >= 90
      letter_grade = 'A'
    elsif grade >= 80
      letter_grade = 'B'
    elsif grade >= 70
      letter_grade = 'C'
    elsif grade >= 60
      letter_grade = 'D'
    end
    letter_grade
  end

  def get_answer(num_questions, start_time)
    answer = -1

    # Timeout is in seconds, so divide by 1000 to get correct units in float point
    if (@time > 0)
      # Calculate Time Left for Timeout
      time_left = calc_time_left(start_time)

      Timeout::timeout(time_left) do
        answer = answer_loop(num_questions)
      end
    else
      answer = answer_loop(num_questions)
    end
    answer
  end

  def calc_time_elapsed(start_time)
    time_elapsed = (Time.now.to_f - start_time.to_f)
    time_elapsed
  end

  def calc_time_left(start_time)
    time_left = (@time * 60).to_f - calc_time_elapsed(start_time)

    # Deal with potential negative number, I never experienced it, but I could see heavy CPU usage or some other
    # Waiting or thread starvation create a problem.
    if time_left < 0
      time_left = 0
    end

    time_left # Return
  end

  def answer_loop(num_questions)
    valid_answer = false

    print 'Select an answer (1-' + num_questions.to_s + '): '
    while !valid_answer do
      answer_string = STDIN.gets.chomp

      if answer_string.is_integer?
        answer = answer_string.to_i
        if answer < 1 || answer > num_questions
          print "out of selection range, pick between 1-" + num_questions.to_s + ": "
        else
          valid_answer = true
        end
      else
        print "not a valid number, pick between 1-" + num_questions.to_s + ": "
      end

    end
    answer # Force this as last assignment for return, don't need to run reassignment interestingly
  end
end



