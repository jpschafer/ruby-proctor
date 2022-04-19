#gui.rb

#Include Dir for OCRA
$:.unshift File.dirname($0)

# includes
require 'os'

if OS.windows?
  require 'rubygems'
  require 'bundler/setup'

  require 'tk'
  require 'thread'

  require 'ruby_proctor/constants.rb'
  require 'ruby_proctor/exam.rb'
  require 'ruby_proctor/question.rb'
  require 'ruby_proctor/processor.rb'
  require 'ruby_proctor/proctor.rb'
  require 'ruby_proctor/string_ext.rb'

  include Constants

  def ruby_proctor_gui
    proctoring = TkVariable.new # Variable Used to Let Screen Behave Differently
    proctoring.value = false

    # Main Menu
    root = TkRoot.new { title "Ruby Proctor - Main Menu" }

    logo = TkPhotoImage.new()
    logo.file = __dir__ + "/logo.gif"

    logo_label = TkLabel.new(root) do
      image logo
      grid('row'=>0, 'column'=>0, 'padx'=>25, 'pady'=>5, 'columnspan'=>1, 'sticky'=>'WE')
    end

    new_quiz = TkButton.new(root) do
      text "New Quiz"
      grid('row'=>1, 'column'=>0, 'padx'=>25, 'pady'=>5, 'columnspan'=>1, 'sticky'=>'WE')
    end
    new_quiz.comman = Proc.new {
      configuration(root)
    }

    view_log = TkButton.new(root) do
      text "View Quiz Log"
      grid('row'=>2, 'column'=>0, 'padx'=>25, 'pady'=>5, 'columnspan'=>1, 'sticky'=>'WE')
    end
    view_log.comman = Proc.new {
      #configuration()
    }

    exit = TkButton.new(root) do
      text "Exit"
      grid('row'=>3, 'column'=>0, 'padx'=>25, 'pady'=>5, 'columnspan'=>1, 'sticky'=>'WE')
    end
    exit.comman = Proc.new {
      root.destroy()
    }


    #configuration()

    Tk.mainloop
  end

  def configuration(root)
    # File Dialogue

    configuration_top = TkToplevel.new { title "Ruby Proctor - Quiz Configuration" }
    #root = TkRoot.new { title "Ruby Proctor - Configuration" }
    #root.grid_columnconfigure(1, :weight=>1);

    filepath = TkVariable.new
    number_questions = TkVariable.new
    time_limit = TkVariable.new

    file_entry = TkEntry.new(configuration_top) do
      grid('row'=>0, 'column'=>0, 'padx'=>5, 'pady'=>5, 'columnspan'=>4, 'sticky'=>'WE')
    end

    button = TkButton.new(configuration_top) do
      text "Open"
      grid('row'=>0, 'column'=>4, 'padx'=>5, 'pady'=>5)
    end

    button.comman = Proc.new {
      l_value = Tk.getOpenFile
      if !l_value.empty?
        filepath.value = l_value
      end
    }

    file_entry.textvariable = filepath

    # Number of Questions
    lb1 = TkLabel.new(configuration_top) do
      text 'Number of Questions: '
      #background "yellow"
      #foreground "blue"
      grid('row'=>1, 'column'=>0)
      end

    number_questions_entry = TkEntry.new(configuration_top) do
      grid('row'=>1, 'column'=>1, 'padx'=>5, 'pady'=>5)
      #pack("side" => "left",  "padx"=> "50", "pady"=> "50")
    end

    number_questions_entry.textvariable = number_questions

    # Time Limit
    lb2 = TkLabel.new(configuration_top) do
      text 'Time Limit (Minutes): '
      #background "yellow"
      # foreground "blue"
      grid('row'=>1, 'column'=>2)
      end
    time_limit_entry = TkEntry.new(configuration_top) do
      grid('row'=>1, 'column'=>3, 'padx'=>5, 'pady'=>5)
      #pack("side" => "left",  "padx"=> "50", "pady"=> "50")
    end

    time_limit_entry.textvariable = time_limit

    # Load Quiz Button
    load_button = TkButton.new(configuration_top) do
      text "Load Quiz"
      grid('row'=>1, 'column'=>4, 'padx'=>5, 'pady'=>5)
      #pack("side" => "bottom",  "padx"=> "50", "pady"=> "50")
    end

    load_button.comman = Proc.new {
      processing_window(root, configuration_top, filepath, number_questions, time_limit)
    }

    file_entry.textvariable = filepath

  end

  def processing_window(root, configuration_top, filepath, number_questions, time_limit)


    if number_questions
      if number_questions.to_s.is_integer?
        if number_questions.to_i <= 0 || number_questions.to_i > Constants::QUIZ_MAX_QUESTIONS
          Tk.messageBox(
            'type' => 'ok',
            'icon' => 'info',
            'title' => 'Number of Questions outside of Range',
            'message' => 'Number of questions must be greater than 0 but no more than 10,000. Specifying more questions than the provided answer key file has will just use all questions available, no repeats'
          )
          return
        end
      else
        Tk.messageBox(
          'type' => 'ok',
          'icon' => 'info',
          'title' => 'Invalid Number of Questions',
          'message' => 'Make sure # of Questions is a valid integer!'
        )
        return
      end
    end

    if time_limit
      if time_limit.to_s.is_integer?
        if time_limit.to_i <= 0
          Tk.messageBox(
            'type' => 'ok',
            'icon' => 'info',
            'title' => 'Time Limit was Less than or equal to 0',
            'message' => 'Time Limit must be a positive number (If you want Unlimited Time, leave input blank)'
          )
          return
        end
      else
        Tk.messageBox(
          'type' => 'ok',
          'icon' => 'info',
          'title' => 'Time Limit must be a number greater than 0',
          'message' => 'Leave Minutes Blank if you want unlimited time.'
        )
        return
      end
    end

    if(!File.exist?(filepath))
      Tk.messageBox(
        'type' => 'ok',
        'icon' => 'info',
        'title' => 'File Not Found',
        'message' => 'File was not found, please make sure your filepath is valid!'
      )
      return
    end

    processing_top = TkToplevel.new {
      title "Ruby Proctor - Processing"
      resizable false, false
    }

    loading_label = TkLabel.new(processing_top) do
      text 'Loading ...'
      background "blue"
      foreground "white"
      grid('row'=>1, 'column'=>2, 'ipadx'=>25, 'ipady'=>5)
    end

    # Loading Indicator
    # loading_top = TkToplevel.new { title "Processing Quiz ..." }
    #progress_bar = Tk::ProgressBar.new(loading_top)
    # progress_bar.pack("side" => 'bottom')
    #progress_bar.mode = indeterminate

    processor = Processor.new(filepath, number_questions)

    # Try to Process, and cleanly display any exceptions
    Thread.new {
      begin
        exam = processor.process()
        configuration_top.destroy();

        exam(exam, time_limit.to_i, root);

      rescue => e

        Tk.messageBox(
          'type' => 'ok',
          'icon' => 'error',
          'title' => 'Exception Occurred',
          'message' => 'Error Processing Exam File: ' + e.message
        )

        puts e.backtrace
      ensure
        processing_top.destroy()
      end
    }
  end

  def exam(exam, time_limit, root)
    # # Start Officiating Exam
    # proctor = Proctor.new(exam, time)
    # proctor.officiate_exam

    time_left = TkVariable.new

    Thread.new {
      time_limit.downto(0) do |i|
        time_left.value = i
        sleep 60
      end
    }

    display_question(exam, 0)
  end

  def display_question(exam, question_num)
    human_question_num = question_num + 1

    question_window = TkToplevel.new { title "Ruby Proctor - Quiz Question #" + human_question_num.to_s }

    # Number of Questions
    question_label = TkLabel.new(question_window) do
      text human_question_num.to_s + ". " + exam.questions[0].question
      #background "yellow"
      #foreground "blue"
      pack('side' => 'top', 'fill' => 'x')
    end

    answer = TkVariable.new
    answer_num = 1
    exam.questions[question_num].answers.each do |choice|
      TkRadioButton.new(question_window) {
        text answer_num.to_s + ". " + choice
        variable answer
        value 'top'
        anchor 'w'
        pack('side' => 'top', 'fill' => 'x')
      }
      answer_num += 1
    end

    if (question_num > 0)
      previous_button = TkButton.new(question_window) {
        text 'Back'
        pack('side' => 'left', 'fill' => 'x')

      }

      previous_button.comman = Proc.new {
        display_question(exam, question_num - 1)
        question_window.destroy()
      }
    end
    if (exam.questions.length > human_question_num)
      next_button = TkButton.new(question_window) {
        text 'Next'
        pack('side' => 'left', 'fill' => 'x')
      }

      next_button.comman = Proc.new {
        display_question(exam, question_num + 1)
        question_window.destroy()
      }
    end

    submit_button = TkButton.new(question_window) {
      text 'Submit'
      pack('side' => 'left', 'fill' => 'x')
    }

    submit_button.comman = Proc.new {
      #display_question(exam, question_num + 1)
      question_window.destroy()
    }
  end
end