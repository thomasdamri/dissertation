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

  #Can use with column graph or line graph
  def wholeTeamWeeklyTaskCount()
    data = team.student_tasks.group_by_week(:task_target_date).count
    return data
  end

  def uniqueStudentTaskCount()
    graph_title = "Student Tasks Created Weekly"
    y_axis = "Task Creation Count"
    x_axis = "Week Start Date"
    data = {name: user.real_display_name, data: student_tasks.group_by_week(:task_start_date).count}
    return data
  end

  #Use with line graph
  def teamTaskCountComparison()
    graph_title = "Student Tasks Created Weekly"
    y_axis = "Task Creation Count"
    x_axis = "Week Start Date"
    data = team.student_teams.map { | team_member|{
      name: team_member.user.real_display_name, data: team_member.student_tasks.group_by_week(:task_start_date).count
    }}
    return data
  end

end
