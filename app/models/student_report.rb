class StudentReport < ApplicationRecord

  belongs_to :student_team
  has_one :user, through: :student_team


  def gets_collection(type, student_team_id)
    student = StudentTeam.find_by(id: student_team_id)
    team_id = student.teams.id
    students = StudentTeam.where("team_id = ?", team_id)
    if type == "User" 
      @item_list = ["1", "2", "3"]
    elsif type == "Grade" 
      @item_list = ["4", "5", "6"]
    elsif type == "Task" 
      @item_list = ["7", "8", "9"]
    else
      @item_list = ["10", "11", "12"]
    end
  end

  def reporting_int_to_string
    case report_object
    when 0
      return "User"
    when 1
      return "Grade"
    when 2
      return "Task"
    else
      return "Team"
    end
  end

  def get_report_object
    case report_object
    when 0
      return StudentTeam.find(report_object_id)
    when 1
      return "Grade"
    when 2
      return StudentTask.find(report_object_id)
    else
      return Team.find(report_object_id)
    end

  end


end
