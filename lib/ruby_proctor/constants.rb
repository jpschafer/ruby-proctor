require 'os'

module Constants
  COMMENT = '*'
  Q_START = '@Q'
  A_START = '@A'
  A_END = '@E'

  QUESTION_NUM_LINES = 10
  QUIZ_MAX_QUESTIONS = 10000

  QUIZ_FILE_NAME = OS.windows? ? "quizlog.dat" : ".quizlog"
end
