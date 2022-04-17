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


  # Has many weighting results (one per completed assessment)
  has_many :student_weightings, dependent: :destroy
  
  has_many :student_tasks, dependent: :destroy
  has_many :student_reports
  has_many :student_chats

  # Has many AssessmentResults written by the user
  has_many :author_results, foreign_key: 'author_id', class_name: 'AssessmentResult', dependent: :destroy
  # Has many AssessmentResults written about the user
  has_many :target_results, foreign_key: 'target_id', class_name: 'AssessmentResult', dependent: :destroy
  

  # A user can only be added to a team once
  validates :user, uniqueness: {scope: :team}

  def self.getName(student_team_id)
    return StudentTeam.find_by(id: student_team_id).user.real_display_name
  end

  def uniqueStudentTaskCount(range)
    table_data = {}
    table_data["graph_type"] = 0
    table_data["graph_title"] = "Student Tasks Created Weekly"
    table_data["data"] = student_tasks.group_by_week(:task_start_date, range: range).count
    table_data["xtitle"] = "Date (Weeks)"
    table_data["ytitle"] = "Task Creation Count"
    return table_data
  end

  def studentCompleteTaskWeek(range)
    table_data = {}
    table_data["graph_type"] = 0
    table_data["graph_title"] = "Student Tasks Completed Weekly"
    table_data["data"] = student_tasks.group_by_week(:task_complete_date, range: range).count
    table_data["xtitle"] = "Date (Weeks)"
    table_data["ytitle"] = "Task Complete Count"
    return table_data
  end

  def studentWeeklyTeamHours(range)
    data = {}
    data[user.real_display_name] = 
    puts(data.inspect)
    table_data = {}
    table_data["graph_type"] = 0
    table_data["graph_title"] = "Hours Logged per Week"
    table_data["data"] = student_tasks.where.not(task_complete_date: nil).group_by_week(:task_complete_date, range: range).sum("hours")
    table_data["xtitle"] = "Date (Weeks)"
    table_data["ytitle"] = "Time Logged (Hours)"
    return table_data
  end

  def easyMediumHardStudentComparison()
    data = {}
    data["Easy"] = 0
    data["Medium"] = 0
    data["Hard"] = 0
    student_tasks.each do |st|
      if st.task_difficulty==0
        data["Easy"] += 1
      elsif st.task_difficulty==1
        data["Medium"] += 1
      else 
        data["Hard"] += 1
      end
    end
    table_data = {}
    table_data["graph_type"] = 3
    table_data["graph_title"] = "Comparison between Easy, Medium, Hard Task Count"
    table_data["data"] = data
    table_data["xtitle"] = "Task Difficulty"
    table_data["ytitle"] = "Task Count"
    return table_data
  end

  #Use with line graph
  def teamTaskCountComparison(range)

    data = team.student_teams.map { | team_member|{
      name: team_member.user.real_display_name, data: team_member.student_tasks.group_by_week(:task_start_date, range: range).count
    }}

    table_data = {}
    table_data["graph_type"] = 0
    table_data["graph_title"] = "Task Creation Counts per Week"
    table_data["data"] = StudentTeam.replaceKeysWithWeekNumber(data)
    table_data["xtitle"] = "Date (Weeks)"
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

  def getWeeklyTeamHours(range)
    data = team.student_teams.map { | team_member|{
      name: team_member.user.real_display_name, data: team_member.student_tasks.where.not(task_complete_date: nil).group_by_week(:task_complete_date, range: range).sum("hours")
    }}

    table_data = {}
    table_data["graph_type"] = 0
    table_data["graph_title"] = "Hours Logged per Week"
    table_data["data"] = StudentTeam.replaceKeysWithWeekNumber(data)
    table_data["xtitle"] = "Date (Weeks)"
    table_data["ytitle"] = "Time Logged (Hours)"

    return table_data
  end

  def self.createTeamArray(student_team_id, team_id)
    select_options = [["Team", -1], ["Myself", student_team_id]]
    users = StudentTeam.where(student_teams:{team_id: team_id})
    for u in users do
      if u.id.to_i != student_team_id.to_i 
        select_options.push([u.user.real_display_name, u.id])
      end
    end
    return select_options
  end

  def getTotalHoursLoggedTeam()
    data = {}
    team.student_teams.each do |member|
      name = member.user.real_display_name
      data[name] = member.student_tasks.sum(:hours)
    end
    table_data = {}
    table_data["graph_type"] = 1
    table_data["graph_title"] = "Total Time Logged"
    table_data["data"] = data
    table_data["xtitle"] = "Time Logged (Hours)"
    table_data["ytitle"] = "Team Member"
    return table_data
  end

  def getMeetingContributionsPerWeek(range)
    data = team.student_teams.map { | team_member|{
      name: team_member.user.real_display_name, data: team_member.student_chats.group_by_week(:posted, range: range).count
    }}

    table_data = {}
    table_data["graph_type"] = 0
    table_data["graph_title"] = "Weekly Meeting Contribution Count Per Week"
    table_data["data"] = StudentTeam.replaceKeysWithWeekNumber(data)
    table_data["xtitle"] = "Date (Weeks)"
    table_data["ytitle"] = "Messages Sent"
    return table_data
  end

  def percentageOfTasksCompleteOnTimeTeam()
    data = {}
    team.student_teams.each do |member|
      name = member.user.real_display_name
      tasks_finished_on_time = 0
      member.student_tasks.each do |task|
        # If the task has been marked complete and was finished before its target date
        if((task.task_complete_date != nil) && (task.task_target_date >= task.task_complete_date))
          tasks_finished_on_time += 1
        end
      end
      total_tasks = member.student_tasks.count
      if(total_tasks==0)
        on_time_ratio = 0
      else 

        on_time_ratio = (tasks_finished_on_time /total_tasks.to_f) * 100
      end
      data[name] = on_time_ratio
    end
    table_data = {}
    table_data["graph_type"] = 1
    table_data["graph_title"] = "Percentage of Tasks Finished on Time"
    table_data["data"] = data
    table_data["xtitle"] = "Percentage of Tasks finished on Time"
    table_data["ytitle"] = "Team Member"
    return table_data
  end

  def tasksCompletePerWeekTeam(range)
    data = team.student_teams.map { | team_member|{
      name: team_member.user.real_display_name, data: team_member.student_tasks.group_by_week(:task_complete_date, range: range).count
    }}

    table_data = {}
    table_data["graph_type"] = 0
    table_data["graph_title"] = "Tasks Completed per Week"
    table_data["data"] = StudentTeam.replaceKeysWithWeekNumber(data)
    table_data["xtitle"] = "Date (Weeks)"
    table_data["ytitle"] = "Task Completed Count"

    return table_data

  end


  def self.whatIsTeamData()
    output = "Team data is a collection of graphs and tables, representing your teams data.\n"
    output += "Data collected ranges from tasks posted, hours logged, contributions to meetings, etc.\n"
    output += "You can even filter to see data for the whole team, or individual members."
    return output
  end

  def self.whyTeamData()
    output = "The aim of displaying team data is not to act as a competition between team mates to try and do the most work, but is to guide the team in fairly contributing.\n"
    output = "Team data is useful as it squashes a lot of data down into an easy to read and digest form.\n"
    output += "This can come in handy when completing peer assessments, allowing for more accurate ratings. You can also jog your memory, by seeing student data from early into the project.\n"
    output += "Staff will also use this when dealing with reports, as they can quickly look for outliers and anomaly's, without having to look through lots of data."
    return output
  end

  def self.replaceKeysWithWeekNumber(data)
    new_data = []
    data.each do |person_hash, index|
      person_hash[:data] = person_hash[:data].transform_keys.with_index {|k,i| ("Week #{i}")}
      new_data.append(person_hash)
    end
    return new_data
  end

  def get_assessments_with_grades()
    assessments = self.team.uni_module.assessments
    graded_list = []
    assessments.each do |assessment|
      if assessment.has_team_grades?
        graded = [assessment.name, assessment.id]
        graded_list.append(graded)
      end
    end
    return graded_list
  end



end
