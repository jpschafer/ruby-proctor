require 'ruby_proctor/hashify'

class Exam

  attr_accessor :questions, :results

  def initialize(questions)
    @questions = questions
    @results = Results.new
  end

  class Results
    include Hashify
    attr_accessor :uid, :quiz_name, :time_started, :time_completed, :time_elapsed, :time_left, :grade, :letter_grade, :num_correct, :total_questions
  end

end