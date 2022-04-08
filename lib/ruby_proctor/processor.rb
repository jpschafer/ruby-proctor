require 'ruby_proctor/constants'
require 'ruby_proctor/question'
require 'ruby_proctor/exam'
require 'ruby_proctor/string_ext'

include Constants

class Processor

  @@_NOT_COMMENT_PATTERN = '^\s*[^\\' + Constants::COMMENT + ']'
  @@_QUESTION_PATTERN = '^\s*' + Constants::Q_START
  @@_ANSWERS_START_PATTERN = '^\s*' + Constants::A_START
  @@_ANSWERS_END_PATTERN = '^\s*' + Constants::A_END

  class ProcessingError < StandardError
    def initialize(msg="Error Occurred During Processing")
      super
    end
  end

  def initialize(file, max_questions)
    @file = file
    @max_questions = max_questions
  end

  def process
    questions = Array.new

    last_symbol = ''
    line_count = 0
    last_question = Question.new(-1) # Dummy to define type? Weak Types are weird in OO
    last_answer_set = nil

    question_count = 0;

    line_num = 0
    IO.foreach(@file) do |l|
      line_num += 1
      line = l.strip

      if line.match(@@_NOT_COMMENT_PATTERN) && !line.empty? # Check first character isn't *, nor all whitespace/empty
        if line.upcase.match(@@_QUESTION_PATTERN)
          if last_symbol == Constants::A_START
            raise ProcessingError, "Answer Key for previous question was not closed - Line #" + line_num.to_s
          else
              last_symbol = Constants::Q_START
              last_question = Question.new(question_count + 1)
              question_count += 1
          end
        elsif line.upcase.match(@@_ANSWERS_START_PATTERN)
          if !last_question.question.empty?
            if last_symbol == Constants::Q_START
              last_symbol = Constants::A_START
            elsif last_symbol == Constants::A_START
              raise ProcessingError, "Duplicate answer key start symbol - Line #" + line_num.to_s
            elsif last_symbol == Constants::A_END
              raise ProcessingError, "Cannot Have multiple sets of answer keys for one Question - Line #" + line_num.to_s
            else
              raise ProcessingError, "Cannot attribute answer tag to question (orphaned answer key), check file syntax - Line #" + line_num.to_s
            end
          else
            raise ProcessingError, "Question is empty - Line #" + line_num.to_s
          end
        elsif line.upcase.match(@@_ANSWERS_END_PATTERN)
          if (last_question.answers.empty?)
            raise ProcessingError, "Answer Key is empty - Line #" + line_num.to_s
          else
            last_symbol = Constants::A_END
            questions.push(last_question)
            line_count = 0
          end
        else
          if last_symbol == Constants::Q_START # Start Processing Question Lines
            last_question.question += l # Keep Formatting
          elsif last_symbol == Constants::A_START # Get Correct Answer
            if line_count == 0
              if line.is_integer?
                last_question.correct_answer = line.to_i
              else
                raise ProcessingError, "Correct answer not an integer - Line #" + line_num.to_s
              end
            else
              last_question.answers.push(line)
            end
            line_count += 1
          elsif last_symbol == Constants::A_END
            raise ProcessingError, "Free text outside of Question or Answer Key, Add * to beginning if intended to be a comment - Line #" + line_num.to_s
          else
            raise ProcessingError, "Free text before first Question Symbol Add * to beginning if intended to be a comment - Line #" + line_num.to_s
          end
        end
      end
      # process the line of text here
    end

    create_exam(questions)
  end

  def create_exam(questions)
    exam_questions = Array.new

    questions.shuffle! # Shuffles original array by Ruby's internal randomization algorithm

    count = 0
    questions.each do |question|

      # If Max Questions is Specified, Check Limit
      if (@max_questions != -1 && count >= @max_questions)
        break
      end

      exam_questions.push(question)
      count += 1 # Ruby doesnt have incrementation syntax!
    end

    if exam_questions.length == 0
      raise ProcessingError.new "No Questions were processed from the exam file, probably an empty file"
    end

    Exam.new(exam_questions)
  end
end
