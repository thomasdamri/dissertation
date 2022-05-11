class StudentReportsController < ApplicationController

  before_action :authenticate_user!
  authorize_resource


  # GETS data needed for a new report
  def new
    @title = "Creating Report"
    @student_report = StudentReport.new
    @student_report.report_objects.build
    @team_id = StudentTeam.find_by(id: params[:student_team_id]).team.id
    @item_list = []
    @users = StudentTeam.where(student_teams:{team_id: @team_id}).where.not(id: params[:student_team_id])
    for u in @users do
      @item_list.push([u.user.real_display_name, u.id])
    end
    render layout: false
  end

  # POSTS the new report to the database
  def create
    @student_report = StudentReport.new
    # Load params to the new object
    @student_report.report_reason = student_report_params[:report_reason]
    @student_report.object_type = student_report_params[:object_type]
    @student_report.report_date = DateTime.now
    @student_report.student_team_id = params[:student_team_id]
    if @student_report.save
      @latest_id = StudentReport.order(:id).last.id
      # Create the new report items
      if params[:student_report][:report_objects_attributes] != nil 
        params[:student_report][:report_objects_attributes].each_value do |value|
          value[:report_object_id].drop(1).each do |v| 
            @object = ReportObject.new(student_report_id: @latest_id, report_object_id: v)
            @object.save
          end
        end
      end
      redirect_to student_team_dashboard_path(params[:student_team_id])
    else
      redirect_to student_team_dashboard_path(params[:student_team_id]), flash: {error: @student_report.errors.full_messages.join(', ')}
    end
  end

  # GET Route used to show report details
  def show_report
    @title = "Viewing Report"
    @student_report = StudentReport.find(params[:report_id])
    @reporter = @student_report.user
    @pagy_report, @report_objects = pagy(@student_report.report_objects, items: 1)
    # If report is of task type
    if @student_report.object_type == 2
      @student_task_comment = StudentTaskComment.new
      # Check to see if task has been liked by the current user
      if (StudentTaskLike.where(user_id: current_user.id ,student_task_id: params[:task_id]).exists?)
        @like_outcome = "UNLIKE"
      else
        @like_outcome = "LIKE"
      end
    else 
      # Load all of the needed data
      @student_team = @student_report.student_team
      @outgoing_assessments = @student_team.team.uni_module.getUncompletedOutgoingAssessmentCount(@student_team)
      @task = StudentTask.new
      @team_id = StudentTeam.find_by(id:  @student_team.id).team.id
      @item_list = []
      @users = StudentTeam.where(student_teams:{team_id: @team_id})
      for u in @users do
        @item_list.push([u.user.real_display_name, u.id])
      end
      @select_options = StudentTeam.createTeamArray( @student_team.id, @team_id)
      @week_options = @student_team.team.uni_module.createWeekNumToDatesMap()
      @tasks = @student_team.team.student_tasks.order(task_start_date: :desc)
      @tasks_count = @tasks.count
      @pagy, @tasks = pagy(@tasks, items: 10)
      @messages = @student_team.team.get_week_chats(-1, @week_options.values[0].to_date)
    end
  end

  # GET Receives the correct list, depending on the selected report type
  def get_list
    @target = params[:target]
    @selected = params[:selected].to_i
    @student = StudentTeam.find_by(id: 2)
    @team_id = @student.team.id
    @item_list = []
    # If report is type user
    if @selected == 0 
      @users = StudentTeam.where(student_teams:{team_id: @team_id})
      for u in @users do
        @item_list.push([u.user.real_display_name, u.id])
      end
    # Else if report is type grade
    elsif @selected == 1 
      @item_list = @student.get_assessments_with_grades()
    # Else report is type task
    else
      @tasks = StudentTask.joins(:student_team).where("student_teams.team_id = ?", @team_id).select(:task_objective, :id)
      for t in @tasks do
        @item_list.push([t.task_objective, t.id])
      end
    end
    respond_to do |format|
      format.turbo_stream 
    end
  end


  # PATCH Method called when report resolution form is submitted
  def report_resolution
    @student_report = StudentReport.find_by(id: params[:id])
    if(@student_report.report_object==0)
      if(@student_report.update(user_report_resolution_params))
        @student_report.complete = true
        @student_report.save
      end
    # If report is a task report, hide the task
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

  def complete_report_form
    @student_report = StudentReport.find(params[:report_id])
  end

  def show_complete_report
    @student_report = StudentReport.find(params[:report_id])
  end

  # POST method, sets the report as complete
  def complete_report
    @student_report = StudentReport.find(params[:report_id])
    @uni_module = @student_report.student_team.team.uni_module
    if @student_report.update(task_report_resolution_params)
      #Email Reporter
      reporter = @student_report.student_team.user
      StudentMailer.reporter_response(user: reporter, reporter_response: @student_report.reporter_response)

      #Email Reportees
      params[:student_report][:report_objects_attributes].each_value do |report_object| 
        # Email reportees
        if(report_object[:action_taken] && report_object[:emailed_reportee])
          report = ReportObject.find(report_object[:id])
          # If report is for a student
          if(@student_report .object_type==0)
            reportee = StudentTeam.find(report.report_object_id).user
          # If report is for a task, get student and delete the task
          elsif(@student_report.object_type==2)
            task = StudentTask.find(report.report_object_id)
            reportee = task.student_team.user
            task.hidden = true
            task.save
          end
          # Email the reported user
          StudentMailer.reportee_response(user: reportee , reportee_response: report.reportee_response)
        end
      end
      @student_report.handled_by = current_user.id
      @student_report.complete = true
      @student_report.save
      redirect_to @uni_module, notice: "Report successfully resolved"
    else 
      render :complete_report_form
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

    def task_report_resolution_params
      params.require(:student_report).permit(:reporter_response, report_objects_attributes: [:action_taken, :emailed_reportee, :taken_action, :id, :reportee_response])
    end

end 
