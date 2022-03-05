class StudentReportsController < ApplicationController

  before_action :authenticate_user!
  authorize_resource


  # GET /uni_modules/new
  def new
    @title = "Creating Report"
    @student_report = StudentReport.new
    @student_report.report_objects.build
    @team_id = StudentTeam.find_by(id: params[:student_team_id]).team.id
    @item_list = []
    @users = StudentTeam.where(student_teams:{team_id: @team_id})
    for u in @users do
      @item_list.push([u.user.real_display_name, u.id])
    end
    render layout: false
  end

  def create
    @student_report = StudentReport.new
    @student_report.report_reason = student_report_params[:report_reason]
    @student_report.object_type = student_report_params[:object_type]
    @student_report.report_date = Date.today
    @student_report.student_team_id = params[:student_team_id]
    if @student_report.save
      @latest_id = StudentReport.order(:id).last.id
      if params[:student_report][:report_objects_attributes] != nil 
        params[:student_report][:report_objects_attributes].each_value do |value|
          value[:report_object_id].drop(1).each do |v| 
            @object = ReportObject.new(student_report_id: @latest_id, report_object_id: v)
            @object.save
          end
        end
      end
      render 'report_creation_success'
    else
      render 'report_creation_failure'
    end
  end

  # GET /uni_modules/new
  def show
    @title = "Viewing Report"
    @student_report = StudentReport.find(params[:id])
    @reporter = @student_report.user
    @pagy, @report_objects = pagy(@student_report.report_objects, items: 1)
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
      #@users = StudentTeam.where(student_teams:{team_id: @team_id}).select(:id)
      @users = StudentTeam.where(student_teams:{team_id: @team_id})
      for u in @users do
        @item_list.push([u.user.real_display_name, u.id])
      end
    elsif @selected == 1 
      @grade = ["Grade 1", 0]
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



  def report_resolution
    @student_report = StudentReport.find_by(id: params[:id])
    if(@student_report.report_object==0)
      if(@student_report.update(user_report_resolution_params))
        @student_report.complete = true
        @student_report.save
      end
    elsif(@student_report.report_object==2)
      if(@student_report.update(task_report_resolution_params))
        StudentTask.hide_task(@student_report.report_object_id)
        @student_report.complete = true
        @student_report.save
      end
    end
    respond_to do |format|
      format.js
    end
  end


  private
  # Use callbacks to share common setup or constraints between actions.


  #Only allow a list of trusted parameters through.
  def student_report_params
    params.require(:student_report).permit(:object_type, :report_reason, report_objects_attributes: [:report_object_id])
  end

  def user_report_resolution_params
    params.require(:student_report).permit(:reporter_response, :reportee_response, :notify_reportee)
  end
  def normal_report_resolution_params
    params.require(:student_report).permit(:reporter_response)
  end
  def task_report_resolution_params
    params.require(:student_report).permit(:reporter_response, :delete_reported_task)
  end

end