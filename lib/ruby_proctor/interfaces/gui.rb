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

    set_filepath = TkVariable.new
    set_filepath.value = ''

    set_time_limit = TkVariable.new
    set_time_limit.value = ''

    set_number_questions = TkVariable.new
    set_number_questions.value = TkVariable.new
    # Main Menu
    root = TkRoot.new { title "Ruby Proctor - Main Menu" }

    logo = TkPhotoImage.new()
    logo.file = __dir__ + "/logo.gif"

    logo_label = TkLabel.new(root) do
      image logo
      grid('row'=>0, 'column'=>0, 'padx'=>25, 'pady'=>5, 'columnspan'=>1, 'sticky'=>'WE')
    end

    config_quiz = TkButton.new(root) do
      text "Set Options"
      grid('row'=>1, 'column'=>0, 'padx'=>25, 'pady'=>5, 'columnspan'=>1, 'sticky'=>'WE')
    end
    config_quiz.comman = Proc.new {
      configuration(root, set_filepath, set_number_questions, set_time_limit)
    }

    # Apply Quiz Config Button
    load_button = TkButton.new(root) do
      text "Run Quiz"
      grid('row'=>2, 'column'=>0, 'padx'=>25, 'pady'=>5, 'columnspan'=>1, 'sticky'=>'WE')
      #pack("side" => "bottom",  "padx"=> "50", "pady"=> "50")
    end

    load_button.comman = Proc.new {
      processing_window(root, root, set_filepath, set_number_questions, set_time_limit)
    }

    view_log = TkButton.new(root) do
      text "View Scores"
      grid('row'=>3, 'column'=>0, 'padx'=>25, 'pady'=>5, 'columnspan'=>1, 'sticky'=>'WE')
    end
    view_log.comman = Proc.new {
      view_log(root)
    }

    exit = TkButton.new(root) do
      text "Exit"
      grid('row'=>4, 'column'=>0, 'padx'=>25, 'pady'=>5, 'columnspan'=>1, 'sticky'=>'WE')
    end
    exit.comman = Proc.new {
      root.destroy()
    }

    root.update()
    root['geometry'] = calc_center_geometry(root, root.winfo_width(), root.winfo_height)

    Tk.mainloop
  end

  def configuration(root, set_filepath, set_number_questions, set_time_limit)

    new_filepath = TkVariable.new
    new_filepath.value = set_filepath.value
    new_time_limit = TkVariable.new
    new_time_limit.value = set_time_limit.value
    new_number_questions = TkVariable.new
    new_number_questions.value = set_number_questions.value

    configuration_top = TkToplevel.new { title "Ruby Proctor - Quiz Configuration" }
    configuration_top.grab_set()

    # configuration_top.protocol("WM_DELETE_WINDOW", Proc.new {
    #   put("test!")
    # })

    #Tk.root.protocol “WM_DELETE_WINDOW”, proc {puts “foo”}

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
        new_filepath.value = l_value
      end
    }

    file_entry.textvariable = new_filepath

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

    number_questions_entry.textvariable = new_number_questions

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

    time_limit_entry.textvariable = new_time_limit

    # Apply Quiz Config Button
    load_button = TkButton.new(configuration_top) do
      text "Apply"
      grid('row'=>1, 'column'=>4, 'padx'=>5, 'pady'=>5)
      #pack("side" => "bottom",  "padx"=> "50", "pady"=> "50")
    end

    load_button.comman = Proc.new {

      if validate(new_filepath, new_number_questions, new_time_limit)
        configuration_top.destroy();
        set_filepath.value = new_filepath.value
        set_number_questions.value = new_number_questions.value
        set_time_limit.value = new_time_limit.value
      end

      #processing_window(root, configuration_top, filepath, number_questions, time_limit)
    }
    configuration_top.update()
    configuration_top['geometry'] = calc_center_geometry(configuration_top, configuration_top.winfo_width(), configuration_top.winfo_height)
    #file_entry.textvariable = new_filepath

  end


  def validate(filepath, number_questions, time_limit)

    if number_questions
      if number_questions.to_s.is_integer?
        if number_questions.to_i <= 0 || number_questions.to_i > Constants::QUIZ_MAX_QUESTIONS
          Tk.messageBox(
            'type' => 'ok',
            'icon' => 'info',
            'title' => 'Number of Questions outside of Range',
            'message' => 'Number of questions must be greater than 0 but no more than 10,000. Specifying more questions than the provided answer key file has will just use all questions available, no repeats'
          )
          return false
          return false
        end
      elsif (number_questions != '')
        Tk.messageBox(
          'type' => 'ok',
          'icon' => 'info',
          'title' => 'Invalid Number of Questions',
          'message' => 'Make sure # of Questions is a valid integer!'
        )
        return false
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
          return false
        end
      elsif (time_limit != '')
        Tk.messageBox(
          'type' => 'ok',
          'icon' => 'info',
          'title' => 'Time Limit must be a number greater than 0',
          'message' => 'Time Limit must be a number greater than 0 *Leave Minutes Blank if you want unlimited time)'
        )
        return false
      end
    end

    if(!File.exist?(filepath))
      Tk.messageBox(
        'type' => 'ok',
        'icon' => 'info',
        'title' => 'File Not Found',
        'message' => 'File was not found, please make sure your filepath is valid!'
      )
      return false
    end
    return true
  end

  def calc_center_geometry(win, window_width, window_height)
    screen_width = win.winfo_screenwidth()
    screen_height = win.winfo_screenheight()

    x = ((screen_width/2) - (window_width/2)).to_i
    y = ((screen_height/2) - (window_height/2)).to_i


    "%sx%s+%i+%i" % [window_width, window_height, x, y]
  end

  def processing_window(root, configuration_top, filepath, number_questions, time_limit)

    if validate(filepath, number_questions, time_limit)
      processing_top = TkToplevel.new {
        title "Ruby Proctor - Processing"
        resizable false, false
        overrideredirect 1
      }

      processing_top['geometry'] = calc_center_geometry(processing_top, 100, 30)

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

      # Ruby is really weird with Local & Instance Variables
      if (number_questions.value.empty?)
        processor = Processor.new(filepath, -1)
      else
        processor = Processor.new(filepath, number_questions)
      end
      # Try to Process, and cleanly display any exceptions
      Thread.new {
        begin
            exam = processor.process()

            if (time_limit.value.empty?)
              exam(exam, -1, root)
            else
              exam(exam, time_limit.to_i, root)
            end
        rescue => e
          Tk.messageBox(
            'type' => 'ok',
            'icon' => 'error',
            'title' => 'Processing Exception Occurred',
            'message' => 'Error Processing Exam File: ' + e.message
          )

          puts e.backtrace
        ensure
          processing_top.destroy()
        end
      }
    end
  end

  def exam(exam, time_limit, root)
    # # Start Officiating Exam
    # proctor = Proctor.new(exam, time)
    # proctor.officiate_exam

    time_left = TkVariable.new
    start_time = Time.now

    question_window = TkToplevel.new {  }
    question_window.grab_set()

    thread = false
    if (time_limit && time_limit > 0)
      thread = Thread.new {
        time_limit.downto(0) do |i|
          time_left.value = i

          if (i > 0)
            sleep 60
          end
        end

        proctor = Proctor.new(exam, time_limit)
        proctor.grade_exam(start_time)

        question_window.destroy()

        logger = Logger.new
        logger.write_to_log(exam)

        display_results(exam.results)

      }
    end

    display_question(exam, 0, question_window, true, start_time, time_left, thread, time_limit)
  end

  def display_question(exam, question_num, question_window, initialize, start_time, time_left, timer_thread, time_limit)

    human_question_num = question_num + 1

    question_window['title'] = "Ruby Proctor - Quiz Question #" + human_question_num.to_s

    if !initialize
      question_window.winfo_children().each { |widgets|
        widgets.destroy()
      }
    end

    # Timer
    if (timer_thread)
      time_left_num = TkLabel.new(question_window) {
        text "Time Left (Minutes): "
        pack('side' => 'top', 'padx'=>5, 'pady'=>5)
      }

      time_left_text = TkEntry.new(question_window) {
        textvariable time_left
        pack('side' => 'top', 'padx'=>5, 'pady'=>5)
        state 'disabled'
        justify 'center'
      }
    end

    TkSeparator.new(question_window) do
      pack('fill' => 'x')
    end

    #Question
    question_label = TkLabel.new(question_window) do
      text human_question_num.to_s + ". " + exam.questions[question_num].question
      #background "yellow"
      #foreground "blue"
      anchor 'w'
      pack('side' => 'top', 'fill' => 'x', 'padx'=>5, 'pady'=>5)
    end

    answer = TkVariable.new
    answer.value = exam.questions[question_num].selected_answer
    answer_num = 1

    exam.questions[question_num].answers.each do |choice|
      TkRadioButton.new(question_window) {
        text answer_num.to_s + ". " + choice
        variable answer
        value answer_num
        anchor 'w'
        pack('side' => 'top', 'fill' => 'x')
      }
      answer_num += 1
    end

    TkSeparator.new(question_window) do
      pack('fill' => 'x')
    end

    previous_button = TkButton.new(question_window) {
      text 'Back'
      pack('side' => 'left', 'fill' => 'x', 'padx'=>5, 'pady'=>5)

    }

    previous_button.comman = Proc.new {
      exam.questions[question_num].selected_answer = answer.value
      display_question(exam, question_num - 1, question_window, false, start_time, time_left, timer_thread, time_limit)
    }

    next_button = TkButton.new(question_window) {
      text 'Next'
      pack('side' => 'left', 'fill' => 'x', 'padx'=>5, 'pady'=>5)
    }

    next_button.comman = Proc.new {
      exam.questions[question_num].selected_answer = answer.value
      display_question(exam, question_num + 1, question_window, false, start_time, time_left, timer_thread, time_limit)
    }

      if (1 == human_question_num)
        previous_button['state'] = 'disabled'
      end

      if (exam.questions.length == human_question_num)
        next_button['state'] = 'disabled'
      end

      submit_button = TkButton.new(question_window) {
      text 'Submit'
      pack('side' => 'right', 'fill' => 'x', 'padx'=>5, 'pady'=>5)
    }

    submit_button.comman = Proc.new {
      #display_question(exam, question_num + 1)
      answer = Tk.messageBox(
        'type' => 'yesno',
        'icon' => 'question',
        'title' => 'Ready to Submit?',
        'message' => 'Are You Wanting to Submit this Quiz?'
      )

      if (answer)
        if (timer_thread)
          timer_thread.kill()
        end

        proctor = Proctor.new(exam, time_limit)
        proctor.grade_exam(start_time)

        question_window.destroy()

        logger = Logger.new
        logger.write_to_log(exam)

        display_results(exam.results)

      end
    }

    #if question_num == 0
      question_window['geometry'] = ""
      question_window.update()
      question_window['geometry'] = calc_center_geometry(question_window, question_window.winfo_width(), question_window.winfo_height)

    #end
  end

  def display_results(results)
    results_win = TkToplevel.new { title "Ruby Proctor - Quiz Configuration" }
    results_win.grab_set()

    display_result_attribute(results_win, 0, "Number of Correct Questions", results.num_correct.to_s + ' / ' + results.total_questions.to_s)
    display_result_attribute(results_win, 1, "Grade %", results.grade.to_s)
    display_result_attribute(results_win, 2, "Letter Grade", results.letter_grade)
    display_result_attribute(results_win, 3, "Time Started", results.time_started)
    display_result_attribute(results_win, 4, "Time Completed", results.time_completed)
    display_result_attribute(results_win, 5, "Time Elapsed", results.time_elapsed)

    if (results.time_left)
      display_result_attribute(results_win, 6, "Time Left", results.time_left)
    end

    TkSeparator.new(results_win) do
      grid('row'=>7, 'column'=>0, 'columnspan'=>2, 'sticky'=>'WE')
    end

    ok_button = TkButton.new(results_win) {
      text 'OK'
      grid('row'=>8, 'column'=>0, 'padx'=>10, 'pady'=>10, 'columnspan'=>2, 'sticky'=>'WE')
    }

    ok_button.comman = Proc.new {
      results_win.destroy()
    }
  end

  def view_log(root)
    log_top = TkToplevel.new { title "Ruby Proctor - Quiz Log" }
    log_top.grab_set()

    list = TkListbox.new(log_top) do
      #width 10
      height 10
      setgrid 1
      selectmode 'browse'
      pack('fill' => 'x')
    end

    logger = Logger.new
    quiz_attempts = logger.read_from_log

    quiz_num = 1
    for attempt in quiz_attempts do
      list.insert(quiz_num - 1, quiz_num.to_s + ". - " + attempt.quiz_name)
      quiz_num += 1
    end

    open_button = TkButton.new(log_top) {
      text 'Open Results'
      pack('side' => 'right', 'padx'=>5, 'pady'=>5)
    }

    open_button.comman = Proc.new {
      if (list.curselection().length > 0)
        display_results(quiz_attempts[list.curselection()[0]])
      else
        Tk.messageBox(
          'type' => 'ok',
          'icon' => 'error',
          'title' => 'No Quiz File Selected!',
          'message' => 'Cannot Open, No Quiz File Selected'
        )
      end
    }

    log_top.update()
    log_top['geometry'] = calc_center_geometry(log_top, 10, 10)

  end

  def display_result_attribute(win, row, name, value)

    tk_value = TkVariable.new
    tk_value.value = value

    # Number of Questions
    TkLabel.new(win) do
      text name + ":"
      #background "yellow"
      #foreground "blue"
      grid('row'=>row, 'column'=>0, 'padx'=>5, 'pady'=>5)
    end

    entry = TkEntry.new(win) do
      grid('row'=>row, 'column'=>1, 'padx'=>5, 'pady'=>5)
      #pack("side" => "left",  "padx"=> "50", "pady"=> "50")
      textvariable tk_value
      state 'disabled'
    end

    #    entry.state('disabled')
  end
end