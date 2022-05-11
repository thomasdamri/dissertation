class StudentTasksController < ApplicationController

  before_action :authenticate_user!
  before_action :set_task, only: [:edit, :update, :complete]
  authorize_resource

  # GET method which retrieves task details
  def show_student_task
    @student_task = StudentTask.find_by(id: params[:task_id])
    @student_task_comment = StudentTaskComment.new
    @student_team_id = params[:student_team_id]
    respond_to do |format|
      format.js
    end
  end

  def index

  end

  # Get method which sets up new task form
  def new
    @title = "Creating Task"
    @student_task = StudentTask.new
  end

  # POST method which creates a new task into the system
  def create
    @student_task = StudentTask.new(student_task_params)
    # Set params
    @student_task.student_team_id = params[:student_team_id]
    @student_task.task_difficulty = StudentTask.difficulty_string_to_int(student_task_params[:task_difficulty])
    @student_task.task_start_date = DateTime.now
    # If saves, refresh page, if error, refresh the page with an error
    if @student_task.save
      redirect_to student_team_dashboard_path(@student_task.student_team_id)
    else
      redirect_to student_team_dashboard_path(@student_task.student_team_id), flash: {error: @student_task.errors.full_messages.join(', ')}
    end
  end

  # DELETE method which deletes a selected task
  def destroy
    @student_task = StudentTask.find(params[:id])
    student_team_id = @student_task.student_team_id
    @student_task.destroy 
    redirect_to student_team_dashboard_path(student_team_id), notice: 'Task deleted'
  end

  # POST method which creates a new comment onto a post
  def comment
    @comment = StudentTaskComment.new(comment_params)
    @comment.user_id = current_user.id
    @comment.student_task_id = params[:student_task_id]
    @comment.posted_on = DateTime.now
    @student_task = StudentTask.find_by(id: params[:student_task_id])
    if @comment.save
      @comment_outcome = "Comment posted"
    else
      #Need to add something to notify of error
      @comment_outcome = "Comment failed to post"
    end
    respond_to do |format|
      format.js
    end
  end

  # DELETE method which deletes a comment from the system
  def delete_comment
    @comment = StudentTaskComment.find(params[:id])
    student_team_id = @comment.student_team_id
    @comment.destroy
    redirect_to student_team_dashboard_path(student_team_id), notice: 'Comment deleted'

  end

  # POST method which adds a likes/unlikes to a task
  def like_task
    @student_task = StudentTask.find_by(params[:student_task_id])
    @task_id = params[:student_task_id]
    @like_id = ("#like-button"+ params[:student_task_id].to_s)
    # Check to see if student has already liked the task previously
    if (StudentTaskLike.where(user_id: current_user.id ,student_task_id: params[:student_task_id]).exists?)
      @like = StudentTaskLike.find_by(user_id: current_user.id ,student_task_id: params[:student_task_id])
      @like.destroy
      @like_outcome = "LIKE"
    else
      @like = StudentTaskLike.create(user_id: current_user.id, student_task_id: params[:student_task_id])
      @like_outcome = "UNLIKE"
    end
    @student_task = StudentTask.find_by(params[:student_task_id])
    respond_to do |format|
      format.js
    end
  end

  # GET method which returns a students tasks
  def return_task_list
    @student_team = StudentTeam.find_by(id: params[:student_team_id])
    @task = StudentTask.new
    @select_options = StudentTeam.createTeamArray(params[:student_team_id], @student_team.team_id)
    respond_to do |format|
      format.js
    end
  end

  # PATCH method which sets a task as complete
  def complete
    authorize! :complete, @student_task
    @student_task.hours = complete_params[:hours].to_i
    @student_task.task_completed_summary = complete_params[:task_completed_summary]
    # If task saves, render success, else render failure
    if(@student_task.update(complete_params))
      @student_task.task_complete_date = DateTime.now
      @student_task.save
      render 'task_complete_success'
    else
      render 'task_complete_failure'
    end
  end




  private
    def set_task
      @student_task = StudentTask.find(params[:student_task_id])
    end

    #Only allow a list of trusted parameters through.
    def student_task_params
      params.require(:student_task).permit(:task_objective, :task_difficulty, :task_target_date, :student_team_id)
    end


    #Only allow a list of trusted parameters through.
    def comment_params
      params.require(:student_task_comment).permit(:comment, :image)
    end

    #Only allow a list of trusted parameters through.
    def complete_params
      params.require(:student_task).permit(:hours, :task_completed_summary)
    end

end
