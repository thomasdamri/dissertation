class StudentTeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team
  authorize_resource
  
  def index 
    authorize! :manage, @student_team
    @outgoing_assessments = @student_team.team.uni_module.getUncompletedOutgoingAssessmentCount(@student_team)
    @task = StudentTask.new
    @student_report = StudentReport.new
    @student_report.report_objects.build
    @team_id = StudentTeam.find_by(id: params[:student_team_id]).team.id
    @item_list = []
    @users = StudentTeam.where(student_teams:{team_id: @team_id})
    for u in @users do
      @item_list.push([u.user.real_display_name, u.id])
    end
    @select_options = StudentTeam.createTeamArray(params[:student_team_id], @team_id)
    @week_options = @student_team.team.uni_module.createWeekNumToDatesMap()
    @tasks = @student_team.team.student_tasks.order(task_start_date: :desc)
    @tasks_count = @tasks.count
    @pagy, @tasks = pagy(@tasks, items: 10)
    @messages = @student_team.team.get_week_chats(-1, @week_options.values[0].to_date)
  end

  def get_task_list
    authorize! :manage, @student_team
    selected = params[:student_team][:user_id].to_i
    filter = params[:student_team][:team_id].to_i
    if(selected==-1)
      @tasks = StudentTask.selectTeamTasks(selected, filter)
    else
      @tasks = StudentTask.selectTasks(selected, filter)
    end
    @tasks_count = @tasks.count
    @pagy, @tasks = pagy(@tasks, items: 10)
    respond_to do |format|
      format.js
    end
  end

  def team_data_index
    @student_team = StudentTeam.find_by(id: params[:student_team_id])
    authorize! :manage, @student_team
    @select_options = StudentTeam.createTeamArray(params[:student_team_id], @student_team.team.id)
    range = @student_team.team.uni_module.get_week_range()
    @tables = []
    @tables.append(@student_team.teamTaskCountComparison(range))
    @tables.append(@student_team.getTaskCountPerStudent())
    @tables.append(@student_team.getWeeklyTeamHours(range))
    @tables.append(@student_team.getTotalHoursLoggedTeam())
    @tables.append(@student_team.getMeetingContributionsPerWeek(range))
    @tables.append(@student_team.percentageOfTasksCompleteOnTimeTeam())
    @tables.append(@student_team.tasksCompletePerWeekTeam(range))
    respond_to do |format|
      format.js
    end
  end

  def team_data 
    @student_team = StudentTeam.find_by(id: params[:student_team_id])
    authorize! :manage, @student_team
    selected = params[:student_team][:user_id].to_i
    if(selected < 0)
      @student_team = StudentTeam.find_by(id: params[:student_team_id])
      @select_options = StudentTeam.createTeamArray(params[:student_team_id], @student_team.team.id)
      range = @student_team.team.uni_module.get_week_range()
      @tables = []
      @tables.append(@student_team.teamTaskCountComparison(range))
      @tables.append(@student_team.getTaskCountPerStudent())
      @tables.append(@student_team.getWeeklyTeamHours(range))
      @tables.append(@student_team.getTotalHoursLoggedTeam())
      @tables.append(@student_team.getMeetingContributionsPerWeek(range))
      @tables.append(@student_team.percentageOfTasksCompleteOnTimeTeam())
      @tables.append(@student_team.tasksCompletePerWeekTeam(range))
    else
      student_team = StudentTeam.find_by(id: params[:student_team_id])
      @select_options = StudentTeam.createTeamArray(params[:student_team_id], @student_team.team.id)
      student_team = StudentTeam.find_by(id: selected)
      range = @student_team.team.uni_module.get_week_range()
      @tables = []
      @tables.append(student_team.uniqueStudentTaskCount(range))
      @tables.append(student_team.easyMediumHardStudentComparison())
      @tables.append(student_team.studentWeeklyTeamHours(range))
      @tables.append(student_team.studentCompleteTaskWeek(range))
    end
    respond_to do |format|
      format.js 
    end
  end

  def swap_to_assessments
    @student_team = StudentTeam.find_by(id: params[:student_team_id])
    authorize! :manage, @student_team
    @assessments = @student_team.team.uni_module.assessments.order(date_opened: :desc)
    respond_to do |format|
      format.js 
    end
  end

  def swap_to_tasks
    @student_team = StudentTeam.find_by(id: params[:student_team_id])
    authorize! :manage, @student_team
    @select_options = StudentTeam.createTeamArray(params[:student_team_id], @student_team.team.id)
    @tasks = @student_team.team.student_tasks.order(task_start_date: :desc)
    @tasks_count = @tasks.count
    @pagy, @tasks = pagy(@tasks, items: 10)
    respond_to do |format|
      format.js 
    end
  end

  def swap_to_meetings
    @student_team = StudentTeam.find_by(id: params[:student_team_id])
    authorize! :manage, @student_team
    @select_options = StudentTeam.createTeamArray(params[:student_team_id], @student_team.team.id)
    @week_options = @student_team.team.uni_module.createWeekNumToDatesMap()
    @messages = @student_team.team.get_week_chats(-1, @week_options.values[0].to_date)
    respond_to do |format|
      format.js 
    end
  end

  def get_assessment
    authorize! :manage, @student_team
    @assessment = Assessment.find_by(id: params[:assessment_id])
    respond_to do |format|
      format.js { render 'student_assessments/show_assessment'}
    end
  end

  


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_team
      @student_team = StudentTeam.find(params[:student_team_id])
    end
end
