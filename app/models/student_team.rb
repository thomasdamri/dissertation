# == Schema Information
#
# Table name: student_teams
#
#  id      :bigint           not null, primary key
#  user_id :bigint
#  team_id :bigint
#
class StudentTeam < ApplicationRecord

  belongs_to :user
  belongs_to :team

  has_many :student_weightings
  has_many :student_tasks
  has_many :student_reports

  # A user can only be added to a team once
  validates :user, uniqueness: {scope: :team}

  def self.getName(student_team_id)
    return StudentTeam.find_by(id: student_team_id).user.real_display_name
  end

  #Can use with column graph or line graph
  def wholeTeamWeeklyTaskCount()
    data = team.student_tasks.group_by_week(:task_target_date).count
    return data
  end

  def uniqueStudentTaskCount()
    graph_title = "Student Tasks Created Weekly"
    y_axis = "Task Creation Count"
    x_axis = "Week Start Date"
    data = student_tasks.group_by_week(:task_start_date).count
    return data
  end

  #Use with line graph
  def teamTaskCountComparison()

    data = team.student_teams.map { | team_member|{
      name: team_member.user.real_display_name, data: team_member.student_tasks.group_by_week(:task_start_date).count
    }}

    table_data = {}
    table_data["graph_type"] = 0
    table_data["graph_title"] = "Task Creation Counts per Week"
    table_data["data"] = data
    table_data["xtitle"] = "Date"
    table_data["ytitle"] = "Task Creation Count"

    return table_data
  end

  def getTaskCountPerStudent()
    graph_title = "Total Tasks Posted"
    data_hash = team.student_tasks.group(:student_team_id).count
    data = {}
    team.student_teams.each do |member|
      name = member.user.real_display_name
      if (data_hash.key?(member.id))
        data[name] = data_hash[member.id]
      else
        data[name] = 0
      end
    end

    statements = StudentTeam.getTaskCountSummary(data)
    table_data = {}
    #2 means its a pie chart
    table_data["graph_type"] = 2
    table_data["graph_title"] = "Tasks Posted per Student"
    table_data["data"] = data
    table_data["statements"] = statements
    return table_data
  end

  def self.getTaskCountSummary(data_hash)
    statements = []
    #Check if no posts have been created
    if data_hash.values.max == 0
      statements.append("Currently no tasks have been posted")
      return statements
    end
    statements.append(StudentTeam.getAverageTasksPosted(data_hash))
    statements.append(StudentTeam.getLargestValueHash(data_hash))
    statements.append(StudentTeam.getSmallestValueHash(data_hash))
    return statements 
  end

  def self.getLargestValueHash(data_hash)
    #Create list of students with the most posts
    max_students = []
    data_hash.each { |k, v| max_students.append(k) if v == data_hash.values.max}

    #Create the string statement
    statement = ""
    if ( max_students.count == 1 )
      student = max_students.first
      statement += (student.to_s + " has created the most tasks, with " + data_hash[student].to_s + " tasks posted")
    else
      max_students.each do |student|
        statement += (student.to_s + ", ")
      end
      statement += ("have created the most tasks, with "+ data_hash[max_students.first].to_s + " tasks posted")
    end
    return statement
  end

  def self.getSmallestValueHash(data_hash)
    #Create list of students with the most posts
    min_students = []
    data_hash.each { |k, v| min_students.append(k) if v == data_hash.values.min}

    #Create the string statement
    statement = ""
    if ( min_students.count == 1 )
      student = min_students.first
      statement += (student.to_s + " has created the least tasks, with " + data_hash[student].to_s + " tasks posted")
    else
      min_students.each do |student|
        statement += (student.to_s + ", ")
      end
      statement += ("have created the least tasks, with "+ data_hash[min_students.first].to_s + " tasks posted")
    end
    return statement
  end

  def self.getAverageTasksPosted(data_hash)
    total = 0
    data_hash.each { |k, v| total+=v}
    total = total / data_hash.count
    statement = ("Mean tasks posted are "+ total.to_s + " per student")
    return statement
  end

  def getWeeklyTeamHours()
    data = team.student_teams.map { | team_member|{
      name: team_member.user.real_display_name, data: team_member.student_tasks.where.not(task_complete_date: nil).group_by_week(:task_complete_date).sum("hours")
    }}

    table_data = {}
    table_data["graph_type"] = 0
    table_data["graph_title"] = "Hours Logged per Week"
    table_data["data"] = data
    table_data["xtitle"] = "Date"
    table_data["ytitle"] = "Hours Logged"

    return table_data
  end

end
