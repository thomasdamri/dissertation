class StudentTeamsController < ApplicationController
  before_action :authenticate_user!
  authorize_resource

  def index 
    @student_team = StudentTeam.find_by(id: params[:student_team_id])
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
    
    @messages = @student_team.team.get_week_chats(-1, (Date.today-7.day))
  end

  def get_task_list
    selected = params[:student_team][:user_id].to_i
    filter = params[:student_team][:team_id].to_i
    if(selected==-1)
      @tasks = StudentTask.selectTeamTasks(selected, filter)
    else
      @tasks = StudentTask.selectTasks(selected, filter)
    end
    respond_to do |format|
      format.js
    end
  end

  def team_data_index
    @test = StudentTeam.new
    @student_team = StudentTeam.find_by(id: params[:student_team_id])
    @select_options = [["Team", -1]]
    users = StudentTeam.where(student_teams:{team_id: @student_team.team_id})
    for u in users do
      @select_options.push([u.user.real_display_name, u.id])
    end
    @tables = []
    @tables.append(@student_team.teamTaskCountComparison())
    @tables.append(@student_team.getTaskCountPerStudent())
    @tables.append(@student_team.getWeeklyTeamHours())

    respond_to do |format|
      format.js
    end
  end

  def team_data 
    @student_team = StudentTeam.find_by(id: params[:student_team_id])
    selected = params[:student_team][:user_id].to_i
    if(selected < 0)
      @student_team = StudentTeam.find_by(id: params[:student_team_id])
      @table2_data = @student_team.getTaskCountPerStudent()
      respond_to do |format|
        format.js 
      end
    else
      @student_team = StudentTeam.find_by(id: selected)
      @data1 = @student_team.uniqueStudentTaskCount()
      puts(@data1.inspect)
      respond_to do |format|
        format.js {render 'individual_data'}
      end
    end
  end

  def swap_to_assessments
    @assessments = StudentTeam.find_by(id: params[:student_team_id]).team.uni_module.assessments
    puts(@assessments.inspect)
    respond_to do |format|
      format.js 
    end
  end

  def swap_to_tasks
    @student_team = StudentTeam.find_by(id: params[:student_team_id])
    @select_options = StudentTeam.createTeamArray(params[:student_team_id], @student_team.team.id)
    @tasks = @student_team.team.student_tasks.order(task_start_date: :desc)
    respond_to do |format|
      format.js 
    end
  end

  def get_assessment
    @assessment = Assessment.find_by(id: params[:assessment_id])
    puts(@assessment.inspect)
    respond_to do |format|
      format.js { render 'student_assessments/show_assessment'}
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_team
      @student_team = Student_Team.find(params[:student_team_id])
    end

    # # Only allow a list of trusted parameters through.
    # def team_params
    #   params.fetch(:team, {})
    # end
end
