require 'ruby_proctor/question'
require 'ruby_proctor/exam'
require 'ruby_proctor/string_ext'
require 'timeout'

class Proctor

  attr_accessor :exam

  def initialize(exam, time)
    @exam = exam
    @time = time
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

    grade_exam(start_time)

  end

  def grade_exam(start_time)
    num_correct = 0
    exam.questions.each do |question|
      if question.correct_answer.eql?(question.selected_answer)
        num_correct += 1
      end
    end

    puts '################'
    puts '# Exam Results #'
    puts '################'
    puts ''

    # Calculate Percentage
    grade = (num_correct.to_f / exam.questions.length.to_f) * 100

    puts 'Number of Questions Answered Correctly: ' + num_correct.to_s + ' / ' + exam.questions.length.to_s
    puts 'Grade (Percentage): ' + grade.to_s + '%'
    puts 'Letter Grade: ' + get_letter_grade(grade)
    puts 'Time Completed: ' + Time.now.strftime("%m/%d/%Y %I:%M %p")

    if (@time > 0)
      # Calculate Time Left
      time_elapsed = calc_time_elapsed(start_time).round
      time_left = calc_time_left(start_time).round

      time_elapsed_hours = time_elapsed / (60*60)
      time_elapsed_minutes = (time_elapsed / 60) % 60
      time_elapsed_seconds = time_elapsed % 60

      time_left_hours = time_left / (60*60)
      time_left_minutes = (time_left / 60) % 60
      time_left_seconds = time_left % 60

      puts 'Time Elapsed: ' + time_elapsed_hours.to_s + ':' + time_elapsed_minutes.to_s + ':' + time_elapsed_seconds.to_s
      puts 'Time Left: ' + time_left_hours.to_s + ':' + time_left_minutes.to_s + ':' + time_left_seconds.to_s
      puts ""
    end
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



