require 'rails_helper'

RSpec.describe StudentChat, type: :model do

  it 'validates user can only be added to a team once' do 
    u = create :uni_module
    t = create :team, uni_module: u 
    u1 = create :user, username: 'test1', email: 'test1@gmail.com'
    st1 = create :student_team, user: u1, team: t
    st2 = build :student_team, user: u1, team: t
    expect(st1).to be_valid 
    expect(st2).to_not be_valid
  end

  it 'returns the correct name' do 
    u = create :uni_module
    t = create :team, uni_module: u 
    u1 = create :user, username: 'test1', email: 'test1@gmail.com', display_name: "Terry" 
    st1 = create :student_team, user: u1, team: t
    expect(StudentTeam.getName(st1)).to eq ("Terry") 
  end


  describe "#uniqueStudentTaskCount" do
    specify "returns the correct table data" do
      u = create :uni_module
      t = create :team, uni_module: u 
      u1 = create :user, username: 'test1', email: 'test1@gmail.com'
      st1 = create :student_team, user: u1, team: t
      u2 = create :user, username: 'test2', email: 'test2@gmail.com'
      st2 = create :student_team, user: u2, team: t
      st1task1 = create :student_task_one, student_team: st1 
      st1task2 = create :student_task_two, student_team: st1
      st2task1 = create :student_task_one, student_team: st2

      date_range = u.get_week_range()
      graph_data = st1.uniqueStudentTaskCount(date_range)

      expect(graph_data["graph_type"]).to eq 0
      expect(graph_data["graph_title"]).to eq "Student Tasks Created Weekly"
      expect(graph_data["xtitle"]).to eq "Date (Weeks)"
      expect(graph_data["ytitle"]).to eq "Task Creation Count"
      total_tasks = graph_data["data"].values.reduce(:+)
      expect(total_tasks).to eq 2
    end
  end

  describe "#studentCompleteTaskWeek" do
    specify "returns the correct table data" do
      u = create :uni_module
      t = create :team, uni_module: u 
      u1 = create :user, username: 'test1', email: 'test1@gmail.com'
      st1 = create :student_team, user: u1, team: t
      st1task1 = create :student_task_one, student_team: st1 
      st1task2 = create :student_task_complete, student_team: st1

      date_range = u.get_week_range()
      graph_data = st1.studentCompleteTaskWeek(date_range)

      expect(graph_data["graph_type"]).to eq 0
      expect(graph_data["graph_title"]).to eq "Student Tasks Completed Weekly"
      expect(graph_data["xtitle"]).to eq "Date (Weeks)"
      expect(graph_data["ytitle"]).to eq "Task Complete Count"
      total_tasks = graph_data["data"].values.reduce(:+)
      expect(total_tasks).to eq 1
    end
  end

  describe "#studentWeeklyTeamHours" do
    specify "returns the correct table data" do
      u = create :uni_module
      t = create :team, uni_module: u 
      u1 = create :user, username: 'test1', email: 'test1@gmail.com'
      st1 = create :student_team, user: u1, team: t
      st1task1 = create :student_task_one, student_team: st1 
      st1task2 = create :student_task_complete, student_team: st1
      st1task3 = create :student_task_complete, student_team: st1

      date_range = u.get_week_range()
      graph_data = st1.studentWeeklyTeamHours(date_range)

      expect(graph_data["graph_type"]).to eq 0
      expect(graph_data["graph_title"]).to eq "Hours Logged per Week"
      expect(graph_data["xtitle"]).to eq "Date (Weeks)"
      expect(graph_data["ytitle"]).to eq "Time Logged (Hours)"
      total_tasks = graph_data["data"].values.reduce(:+)
      expect(total_tasks).to eq 8
    end
  end

  describe "#easyMediumHardStudentComparison" do
    specify "returns the correct table data" do
      u = create :uni_module
      t = create :team, uni_module: u 
      u1 = create :user, username: 'test1', email: 'test1@gmail.com'
      st1 = create :student_team, user: u1, team: t
      st1task1 = create :student_task_easy, student_team: st1 
      st1task2 = create :student_task_easy, student_team: st1
      st1task3 = create :student_task_medium, student_team: st1
      st1task4 = create :student_task_medium, student_team: st1
      st1task5 = create :student_task_medium, student_team: st1
      st1task6 = create :student_task_hard, student_team: st1
      st1task7 = create :student_task_hard, student_team: st1
      st1task8 = create :student_task_hard, student_team: st1
      st1task9 = create :student_task_hard, student_team: st1

      graph_data = st1.easyMediumHardStudentComparison()

      expect(graph_data["graph_type"]).to eq 3
      expect(graph_data["graph_title"]).to eq "Comparison between Easy, Medium, Hard Task Count"
      expect(graph_data["xtitle"]).to eq "Task Difficulty"
      expect(graph_data["ytitle"]).to eq "Task Count"
      expect(graph_data["data"]["Easy"]).to eq 2
      expect(graph_data["data"]["Medium"]).to eq 3
      expect(graph_data["data"]["Hard"]).to eq 4
    end
  end

  describe "#teamTaskCountComparison" do
    specify "returns the correct table data" do
      u = create :uni_module
      t = create :team, uni_module: u 
      u1 = create :user, username: 'test1', email: 'test1@gmail.com'
      st1 = create :student_team, user: u1, team: t
      u2 = create :user, username: 'test2', email: 'test2@gmail.com'
      st2 = create :student_team, user: u2, team: t
      st1task1 = create :student_task_one, student_team: st1 
      st1task2 = create :student_task_two, student_team: st1
      st2task1 = create :student_task_one, student_team: st2

      date_range = u.get_week_range()
      graph_data = st1.teamTaskCountComparison(date_range)

      expect(graph_data["graph_type"]).to eq 0
      expect(graph_data["graph_title"]).to eq "Task Creation Counts per Week"
      expect(graph_data["xtitle"]).to eq "Date (Weeks)"
      expect(graph_data["ytitle"]).to eq "Task Creation Count"

      total_tasks_1 = (graph_data["data"].first)[:data].values.reduce(:+)
      total_tasks_2 = (graph_data["data"].last)[:data].values.reduce(:+)
      expect(total_tasks_1).to eq 2
      expect(total_tasks_2).to eq 1
    end
  end

  describe "#getTaskCountPerStudent" do
    specify "returns the correct table data" do
      u = create :uni_module
      t = create :team, uni_module: u 
      u1 = create :user, username: 'test1', email: 'test1@gmail.com'
      st1 = create :student_team, user: u1, team: t
      u2 = create :user, username: 'test2', email: 'test2@gmail.com'
      st2 = create :student_team, user: u2, team: t
      st1task1 = create :student_task_one, student_team: st1 
      st1task2 = create :student_task_two, student_team: st1
      st2task1 = create :student_task_one, student_team: st2

      graph_data = st1.getTaskCountPerStudent

      expect(graph_data["graph_type"]).to eq 2
      expect(graph_data["graph_title"]).to eq "Tasks Posted per Student"
      expect(graph_data["statements"].size).to eq 3
    end

    specify "no created posts" do
      u = create :uni_module
      t = create :team, uni_module: u 
      u1 = create :user, username: 'test1', email: 'test1@gmail.com'
      st1 = create :student_team, user: u1, team: t
      u2 = create :user, username: 'test2', email: 'test2@gmail.com'
      st2 = create :student_team, user: u2, team: t

      graph_data = st1.getTaskCountPerStudent

      expect(graph_data["graph_type"]).to eq 2
      expect(graph_data["graph_title"]).to eq "Tasks Posted per Student"
      expect(graph_data["statements"].size).to eq 1
    end

    specify "one student has created posts" do
      u = create :uni_module
      t = create :team, uni_module: u 
      u1 = create :user, username: 'test1', email: 'test1@gmail.com'
      st1 = create :student_team, user: u1, team: t
      u2 = create :user, username: 'test2', email: 'test2@gmail.com'
      st2 = create :student_team, user: u2, team: t
      st1task1 = create :student_task_one, student_team: st1 
      st1task2 = create :student_task_two, student_team: st1

      graph_data = st1.getTaskCountPerStudent

      expect(graph_data["graph_type"]).to eq 2
      expect(graph_data["graph_title"]).to eq "Tasks Posted per Student"
    end
  end

  describe "#getWeeklyTeamHours" do
    specify "returns the correct table data" do
      u = create :uni_module
      t = create :team, uni_module: u 
      u1 = create :user, username: 'test1', email: 'test1@gmail.com'
      st1 = create :student_team, user: u1, team: t
      u2 = create :user, username: 'test2', email: 'test2@gmail.com'
      st2 = create :student_team, user: u2, team: t
      st1task1 = create :student_task_one, student_team: st1 
      st1task2 = create :student_task_two, student_team: st1
      st2task1 = create :student_task_one, student_team: st2

      date_range = u.get_week_range()
      graph_data = st1.getWeeklyTeamHours(date_range)

      expect(graph_data["graph_type"]).to eq 0
      expect(graph_data["graph_title"]).to eq "Hours Logged per Week"
      expect(graph_data["xtitle"]).to eq "Date (Weeks)"
      expect(graph_data["ytitle"]).to eq "Time Logged (Hours)"
    end
  end

  describe "#createTeamArray" do
    specify "returns the correct table data" do
      u = create :uni_module
      t = create :team, uni_module: u 
      u1 = create :user, username: 'test1', email: 'test1@gmail.com', display_name: "Lisa"
      st1 = create :student_team, user: u1, team: t
      u2 = create :user, username: 'test2', email: 'test2@gmail.com', display_name: "Tod"
      st2 = create :student_team, user: u2, team: t


      array = StudentTeam.createTeamArray(st1.id, t.id)
      array2 = StudentTeam.createTeamArray(st2.id, t.id)

      expect(array.include?(["Myself", st1.id])).to eq true
      expect(array.include?(["Team", -1])).to eq true
      expect(array.include?(["Tod", st2.id])).to eq true
      
      expect(array2.include?(["Myself", st2.id])).to eq true
      expect(array2.include?(["Team", -1])).to eq true
      expect(array2.include?(["Lisa", st1.id])).to eq true
    end
  end

  describe "#getTotalHoursLoggedTeam" do
    specify "returns the correct table data" do
      u = create :uni_module
      t = create :team, uni_module: u 
      u1 = create :user, username: 'test1', email: 'test1@gmail.com'
      st1 = create :student_team, user: u1, team: t
      u2 = create :user, username: 'test2', email: 'test2@gmail.com'
      st2 = create :student_team, user: u2, team: t
      st1task1 = create :student_task_one, student_team: st1 
      st1task2 = create :student_task_two, student_team: st1
      st2task1 = create :student_task_one, student_team: st2

      graph_data = st1.getTotalHoursLoggedTeam()

      expect(graph_data["graph_type"]).to eq 1
      expect(graph_data["graph_title"]).to eq "Total Time Logged"
      expect(graph_data["xtitle"]).to eq "Time Logged (Hours)"
      expect(graph_data["ytitle"]).to eq "Team Member"
    end
  end

  describe "#getMeetingContributionsPerWeek" do
    specify "returns the correct table data" do
      u = create :uni_module
      t = create :team, uni_module: u 
      u1 = create :user, username: 'test1', email: 'test1@gmail.com'
      st1 = create :student_team, user: u1, team: t
      u2 = create :user, username: 'test2', email: 'test2@gmail.com'
      st2 = create :student_team, user: u2, team: t
      st1task1 = create :student_task_one, student_team: st1 
      st1task2 = create :student_task_two, student_team: st1
      st2task1 = create :student_task_one, student_team: st2

      date_range = u.get_week_range()
      graph_data = st1.getMeetingContributionsPerWeek(date_range)

      expect(graph_data["graph_type"]).to eq 0
      expect(graph_data["graph_title"]).to eq "Weekly Meeting Contribution Count Per Week"
      expect(graph_data["xtitle"]).to eq "Date (Weeks)"
      expect(graph_data["ytitle"]).to eq "Messages Sent"
    end
  end

  describe "#percentageOfTasksCompleteOnTimeTeam" do
    specify "no tasks completed" do
      u = create :uni_module
      t = create :team, uni_module: u 
      u1 = create :user, username: 'test1', email: 'test1@gmail.com', display_name: "Ted"
      st1 = create :student_team, user: u1, team: t
      u2 = create :user, username: 'test2', email: 'test2@gmail.com', display_name: "Tim"
      st2 = create :student_team, user: u2, team: t
      st1task1 = create :student_task_one, student_team: st1 
      st1task2 = create :student_task_two, student_team: st1
      st2task1 = create :student_task_one, student_team: st2
      
      graph_data = st1.percentageOfTasksCompleteOnTimeTeam()

      expect(graph_data["graph_type"]).to eq 1
      expect(graph_data["graph_title"]).to eq "Percentage of Tasks Finished on Time"
      expect(graph_data["xtitle"]).to eq "Percentage of Tasks finished on Time"
      expect(graph_data["ytitle"]).to eq "Team Member"
      expect(graph_data["data"].values.first).to eq 0
      expect(graph_data["data"].values.last).to eq 0
    end

    specify "all on time" do
      u = create :uni_module
      t = create :team, uni_module: u 
      u1 = create :user, username: 'test1', email: 'test1@gmail.com', display_name: "Ted"
      st1 = create :student_team, user: u1, team: t
      u2 = create :user, username: 'test2', email: 'test2@gmail.com', display_name: "Tim"
      st2 = create :student_team, user: u2, team: t
      st1task1 = create :student_task_complete, student_team: st1 

      graph_data = st1.percentageOfTasksCompleteOnTimeTeam()

      expect(graph_data["graph_type"]).to eq 1
      expect(graph_data["graph_title"]).to eq "Percentage of Tasks Finished on Time"
      expect(graph_data["xtitle"]).to eq "Percentage of Tasks finished on Time"
      expect(graph_data["ytitle"]).to eq "Team Member"
      expect(graph_data["data"].values.first).to eq 100
    end

    specify "all late" do
      u = create :uni_module
      t = create :team, uni_module: u 
      u1 = create :user, username: 'test1', email: 'test1@gmail.com', display_name: "Ted"
      st1 = create :student_team, user: u1, team: t
      u2 = create :user, username: 'test2', email: 'test2@gmail.com', display_name: "Tim"
      st2 = create :student_team, user: u2, team: t
      st1task1 = create :student_task_late, student_team: st1 
      
      graph_data = st1.percentageOfTasksCompleteOnTimeTeam()

      expect(graph_data["graph_type"]).to eq 1
      expect(graph_data["graph_title"]).to eq "Percentage of Tasks Finished on Time"
      expect(graph_data["xtitle"]).to eq "Percentage of Tasks finished on Time"
      expect(graph_data["ytitle"]).to eq "Team Member"
      expect(graph_data["data"].values.first).to eq 0
    end

    specify "50 percent on time" do
      u = create :uni_module
      t = create :team, uni_module: u 
      u1 = create :user, username: 'test1', email: 'test1@gmail.com', display_name: "Ted"
      st1 = create :student_team, user: u1, team: t
      u2 = create :user, username: 'test2', email: 'test2@gmail.com', display_name: "Tim"
      st2 = create :student_team, user: u2, team: t
      st1task1 = create :student_task_complete, student_team: st1 
      st1task2 = create :student_task_late, student_team: st1
      
      graph_data = st1.percentageOfTasksCompleteOnTimeTeam()

      expect(graph_data["graph_type"]).to eq 1
      expect(graph_data["graph_title"]).to eq "Percentage of Tasks Finished on Time"
      expect(graph_data["xtitle"]).to eq "Percentage of Tasks finished on Time"
      expect(graph_data["ytitle"]).to eq "Team Member"
      expect(graph_data["data"].values.first).to eq 50
    end
  end

  describe "#tasksCompletePerWeekTeam" do
    specify "returns the correct table data" do
      u = create :uni_module
      t = create :team, uni_module: u 
      u1 = create :user, username: 'test1', email: 'test1@gmail.com'
      st1 = create :student_team, user: u1, team: t
      u2 = create :user, username: 'test2', email: 'test2@gmail.com'
      st2 = create :student_team, user: u2, team: t
      st1task1 = create :student_task_one, student_team: st1 
      st1task2 = create :student_task_two, student_team: st1
      st2task1 = create :student_task_one, student_team: st2

      date_range = u.get_week_range()
      graph_data = st1.tasksCompletePerWeekTeam(date_range)

      expect(graph_data["graph_type"]).to eq 0
      expect(graph_data["graph_title"]).to eq "Tasks Completed per Week"
      expect(graph_data["xtitle"]).to eq "Date (Weeks)"
      expect(graph_data["ytitle"]).to eq "Task Completed Count"
    end
  end

  describe "#isInTeam?" do
    specify "in team" do
      u = create :uni_module
      t = create :team, uni_module: u 
      u1 = create :user, username: 'test1', email: 'test1@gmail.com'
      st1 = create :student_team, user: u1, team: t
      u2 = create :user, username: 'test2', email: 'test2@gmail.com'
      st2 = create :student_team, user: u2, team: t
      expect(st1.isInTeam?(u2)).to eq true
    end

    specify "not in team" do
      u = create :uni_module
      t = create :team, uni_module: u 
      u1 = create :user, username: 'test1', email: 'test1@gmail.com'
      st1 = create :student_team, user: u1, team: t
      u2 = create :user, username: 'test2', email: 'test2@gmail.com'
      expect(st1.isInTeam?(u2)).to eq false
    end
  end  

  describe '#whatIsTeamData' do 
    it 'returns string correctly' do
      string = StudentTeam.whatIsTeamData()
      expect(string.first).to eq 'T'
      expect(string.last).to eq '.'
    end
  end

  describe '#whyTeamData' do
    it 'returns string correctly' do
      string = StudentTeam.whyTeamData()
      expect(string.first).to eq 'T'
      expect(string.last).to eq '.'
    end
  end

  describe '#get_assessments_with_grades' do
    before(:each) do
      u = create :uni_module
      a = create :assessment, uni_module: u
      q = create :weighted_question, assessment: a, title: 'C'
      t = create :team, uni_module: u
      u1 = create :user
      u2 = create(:student, username: 'test1', email: 'test1@sheffield.ac.uk')
      st1 = create :student_team, user: u1, team: t
      st2 = create :student_team, user: u2, team: t
    end
    it 'no graded assessments' do
      u1 = User.where(username: 'zzz12dp').first
      u2 = User.where(username: 'test1').first
      t = Team.first
      a = Assessment.first

      create :assessment_result_int ,author: u1.student_teams.first, target: u2.student_teams.first, question: a.questions.first
      create :assessment_result_int ,author: u1.student_teams.first, target: u1.student_teams.first, question: a.questions.first
      a.generate_weightings(t)

      expect(u1.student_teams.first.get_assessments_with_grades().size).to eq 0
    end

    it 'one graded one not graded' do
      u1 = User.where(username: 'zzz12dp').first
      u2 = User.where(username: 'test1').first
      t = Team.first
      a = Assessment.first

      create :assessment_result_int ,author: u1.student_teams.first, target: u2.student_teams.first, question: a.questions.first
      create :assessment_result_int ,author: u1.student_teams.first, target: u1.student_teams.first, question: a.questions.first
      create :team_grade, team: t, assessment: a
      a.generate_weightings(t)

      expect(u1.student_teams.first.get_assessments_with_grades().size).to eq 1
    end
  end

end 



  