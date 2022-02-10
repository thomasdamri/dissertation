class StudentTask < ApplicationRecord
  belongs_to :student_team
  has_many :student_task_edits

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


end
