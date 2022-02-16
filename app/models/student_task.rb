class StudentTask < ApplicationRecord
  belongs_to :student_team
  has_many :student_task_edits
  has_many :student_task_comments

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
      return "border-left: 5px solid green;"
    when 2
      return "border-left: 5px solid red;"
    else
      return "border-left: 5px solid yellow;"
    end
  end

  #Returns list of students working on the task
  def get_linked_students()
    test_team = StudentTeam.find_by(id: self.student_team_id)
    user_leader = User.find_by(id: (test_team.user_id))
    student_name = user_leader.real_display_name()
    return student_name
  end



end
