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
      return StudentTask.find_by(id: which_student).student_tasks.where.not(latest_comment_time: nil).order(latest_comment_time: :desc)
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


end
