class Configuration

  attr_accessor :filepath, :num_questions, :time_limit

  def initialize
    @filepath = ''
    @num_questions = 10
    @time_limit = 10
  end
end