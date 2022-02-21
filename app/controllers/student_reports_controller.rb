class StudentReportsController < ApplicationController

  before_action :authenticate_user!
  authorize_resource


  # GET /uni_modules/new
  def new
    @title = "Creating Report"
    @student_report = StudentReport.new
  end

  def get_list
    @target = params[:target]
    @selected = params[:selected]

    @student = StudentTeam.find_by(id: 2)
    @team_id = @student.team.id

    if @selected == "User" 
      @item_list = StudentTeam.where(student_teams:{team_id: @team_id}).select(:id)
    elsif @selected == "Grade" 
      @item_list = ["grade"]
    elsif @selected == "Task" 
      @item_list = StudentTask.joins(:student_team).where("student_teams.team_id = ?", @team_id).select(:id, :task_objective)
    else
      @item_list = []
    end
    puts(@item_list.inspect)
    respond_to do |format|
      format.turbo_stream
    end
  end

end