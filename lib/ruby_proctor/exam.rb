require 'ruby_proctor/hashify'

class Exam

  attr_accessor :questions, :results

  def initialize(quiz_name, questions)
    @questions = questions
    @results = Results.new(quiz_name)
  end

  class Results
    include Hashify
    attr_accessor :uid, :quiz_name, :time_started, :time_completed, :time_elapsed, :time_left, :grade, :letter_grade, :num_correct, :total_questions

    def initialize(quiz_name)
      @quiz_name = quiz_name
    end
  end
end