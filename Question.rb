class Question

  attr_accessor :id, :question, :answers, :correct_answer, :selected_answer

  def initialize(id)
    @id = id
    @question = ''
    @answers = Array.new()
    @correct_answer = nil
    @selected_answer = -1
  end

  def isCorrect()
    @correct_answer == @selected_answer
  end

end