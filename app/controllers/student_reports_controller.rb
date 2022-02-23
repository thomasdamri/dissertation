class StudentReportsController < ApplicationController

  before_action :authenticate_user!
  authorize_resource


  # GET /uni_modules/new
  def new
    @title = "Creating Report"
    @student_report = StudentReport.new
    @team_id = StudentTeam.find_by(id: params[:student_team_id]).team.id
    @item_list = []
    @users = StudentTeam.where(student_teams:{team_id: @team_id}).select(:id)
    for u in @users do
      @item_list.push([u.id, u.id])
    end
  end

  def create
    @student_report = StudentReport.new(student_report_params)
    @student_report.report_date = Date.today
    @student_report.student_team_id = params[:student_team_id]
    if @student_report.save
      redirect_to new_report_path(params[:student_team_id]), notice: 'Thank You, Report Submitted'
    else
      redirect_to new_report_path(params[:student_team_id]), notice: 'Sorry, Report Failed'
    end
  end

  def get_list
    @target = params[:target]
    @selected = params[:selected].to_i

    #Need it so correct student is used
    @student = StudentTeam.find_by(id: 2)
    @team_id = @student.team.id
    @item_list = []
    puts(@selected == 2)
    if @selected == 0 
      @users = StudentTeam.where(student_teams:{team_id: @team_id}).select(:id)
      for u in @users do
        @item_list.push([u.id, u.id])
      end
    elsif @selected == 1 
      @grade = ["Grade Substitute", 0]
      @item_list = @item_list.push(@grade)
    elsif @selected == 2 
      @tasks = StudentTask.joins(:student_team).where("student_teams.team_id = ?", @team_id).select(:task_objective, :id)
      for t in @tasks do
        @item_list.push([t.task_objective, t.id])
      end
    else
      @team = ["My Team", @team_id]
      @item_list.push(@team)
    end
    respond_to do |format|
      format.turbo_stream
    end
  end


  private
  # Use callbacks to share common setup or constraints between actions.


  #Only allow a list of trusted parameters through.
  def student_report_params
    params.require(:student_report).permit(:report_object, :report_object_id, :report_reason)
  end

end