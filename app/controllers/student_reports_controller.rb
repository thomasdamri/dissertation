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
    @item_list = []
    if @selected == "User" 
      @users = StudentTeam.where(student_teams:{team_id: @team_id}).select(:id)
      for u in @users do
        @item_list.push([u.id, u.id])
      end
    elsif @selected == "Grade" 
      @grade = ["Grade Substitute", 0]
      @item_list = @item_list.push(@grade)
    elsif @selected == "Task" 
      @tasks = StudentTask.joins(:student_team).where("student_teams.team_id = ?", @team_id).select(:task_objective, :id)
      for t in @tasks do
        @item_list.push([t.task_objective, t.id])
      end
    else
      @item_list = []
    end
    puts(@item_list.inspect)
    respond_to do |format|
      format.turbo_stream
    end
  end

end