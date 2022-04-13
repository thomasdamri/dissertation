class StudentTask < ApplicationRecord
  belongs_to :student_team
  has_many :student_task_edits, :dependent => :destroy
  has_many :student_task_comments, :dependent => :destroy
  has_many :student_task_likes, :dependent => :destroy

  accepts_nested_attributes_for :student_task_edits, allow_destroy: true

  validates :task_objective, length: { in: 10..300}

  #Takes int input and returns the string version(because its stored as int in the db)
  def self.difficulty_int_to_string(integer_input)
    case integer_input
    when 0
      return "Easy"
    when 2
      return "Hard"
    else
      return "Medium"
    end
  end

  def self.difficulty_string_to_int(string_input)
    case string_input
    when "Easy"
      return 0
    when "Hard"
      return 2
    else
      return 1
    end
  end

  def self.difficulty_int_to_colour(integer_input)
    case integer_input
    when 0
      return "green"
    when 2
      return "red"
    else
      return "yellow"
    end
  end

  def self.difficulty_int_to_style(integer_input)
    case integer_input
    when 0
      return "border-bottom: 7px solid green;"
    when 2
      return "border-bottom: 7px solid red;"
    else
      return "border-bottom: 7px solid yellow;"
    end
  end

  #Returns list of students working on the task
  def get_linked_students()
    test_team = StudentTeam.find_by(id: self.student_team_id)
    user_leader = User.find_by(id: (test_team.user_id))
    student_name = user_leader.real_display_name()
    return student_name
  end

  def self.hide_task(task_id)
    task = StudentTask.find_by(id: task_id)
    task.hidden = true
    task.save
  end

  def self.selectTasks(which_student, what_filter)
    case what_filter
    when 1
      return StudentTeam.find_by(id: which_student).student_tasks.where.not(task_complete_date: nil).order(task_start_date: :desc)
    when 2
      return StudentTeam.find_by(id: which_student).student_tasks.where("task_target_date < ? and task_complete_date IS ? ", Date.today, nil).order(task_target_date: :asc)
    when 3
      return StudentTeam.find_by(id: which_student).student_tasks.order("student_task_likes_count DESC")
    when 4
      return StudentTeam.find_by(id: which_student).student_tasks.order("student_task_comments_count DESC")
    when 5
      return StudentTeam.find_by(id: which_student).student_tasks.where(task_difficulty: 2)
    when 6
      return StudentTeam.find_by(id: which_student).student_tasks.where(task_difficulty: 1)
    when 7
      return StudentTeam.find_by(id: which_student).student_tasks.where(task_difficulty: 0)
    when 8
      return StudentTeam.find_by(id: which_student).student_tasks.where.not(latest_comment_time: nil).order(latest_comment_time: :desc)
    else
      return StudentTeam.find_by(id: which_student).student_tasks.order(task_start_date: :desc)
    end
  end

  def self.selectTeamTasks(which_student, what_filter)
    case what_filter
    when 1
      return StudentTask.where.not(task_complete_date: nil).order(task_start_date: :desc)
    when 2
      return StudentTask.where("task_target_date < ? and task_complete_date IS ? ", Date.today, nil).order(task_target_date: :asc)
    when 3
      return StudentTask.order("student_task_likes_count DESC")
    when 4
      return StudentTask.order("student_task_comments_count DESC")
    when 5
      return StudentTask.where(task_difficulty: 2).order(task_start_date: :desc)
    when 6
      return StudentTask.where(task_difficulty: 1).order(task_start_date: :desc)
    when 7
      return StudentTask.where(task_difficulty: 0).order(task_start_date: :desc)
    when 8
      return StudentTask.where.not(latest_comment_time: nil).order(latest_comment_time: :desc)
    else
      return StudentTask.all.order(task_start_date: :desc)
    end
  end

  def getCommentsWithImages()
    comments = self.student_task_comments.joins(:image_attachment)
    return comments
  end

  def self.whatAreTeamTasks()
    output = "Student Tasks are a way of documenting your progress throughout a project.\n"
    output += "Think of this as a shared team diary, where everybody contributes to documenting the progress of your project.\n"
    output += "A task should take around 1-6 hours to complete, and you should create a separate task for every undertaking you perform."
    output += "Tasks are useful for many reasons. To keep everybody organized and up to date, to collect data which will aid you in completing peer assessments and to help staff with students not contributing fairly."
    return output
  end

  def self.difficultyExplained()
    output = "Student Tasks are marked with a difficulty value; either easy, medium or hard.\n"
    output += "When creating a task, consider the amount of time that you think will be spent on this task, as this value will give your peers a better indication of the task that you are working on.\n"
    output += "A medium task will be a little more lengthier, taking around 2-3 hours.\n"
    output += "Any task larger than this should be marked as hard, letting your team mates know how long you expect to spend on this challenge.\n"
    output += "Ranking tasks based on difficulty will also come in handy, as you may be able to see which tasks students are finding difficult, allowing you to intervene and help out. "
    return output

  end

  def self.commendationsExplained()
    output = "Team interaction is encouraged.\n"
    output += "See a student putting in great work on a task? Give it a like to show your support!\n"
    output += "Comments are also useful for you to discuss the specific task. Perhaps a student has commented that they are finding difficulty somewhere, or experiencing a bug. Push them along with a hint, or a link to a useful webpage.\n"
    output += "The task comment section is also useful to log your progress on the task, connecting a screenshot will also help your team mates get a better picture of what you're currently working on."
    return output
  end

  def self.taskCompletingExplained()
    output = "Once you have finished a task, you should mark it as complete.\n"
    output += "This allows you to summarize the task and work you have completed, as well as giving an accurate number of hours spent on it.\n"
    output += "Be careful when logging hours, as if a student suspects you are inflating your time spent on tasks, you may be reported. \n"
    return output
  end
end
