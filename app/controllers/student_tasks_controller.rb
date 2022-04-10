class StudentTasksController < ApplicationController

  before_action :authenticate_user!
  authorize_resource

  # GET /uni_modules/1
  def show_student_task
    @student_task = StudentTask.find_by(id: params[:task_id])
    @student_task_comment = StudentTaskComment.new
    @student_team_id = params[:student_team_id]
    if (StudentTaskLike.where(user_id: current_user.id ,student_task_id: params[:task_id]).exists?)
      @like_outcome = "UNLIKE"
    else
      @like_outcome = "LIKE"
    end
    respond_to do |format|
      format.js
    end
  end

  def index

  end

  # GET /uni_modules/new
  def new
    @title = "Creating Task"
    @student_task = StudentTask.new

  end

  # GET /uni_modules/1/edit
  def edit
    @title = "Editing Task"
    @student_task = StudentTask.find(params[:id])
    @student_task.student_task_edits.build(previous_target_date: @student_task.task_target_date)
    # render layout: false
  end

  # POST /uni_modules
  def create
    @student_task = StudentTask.new(student_task_params)
    @student_task.student_team_id = params[:student_team_id]
    @student_task.task_difficulty = StudentTask.difficulty_string_to_int(student_task_params[:task_difficulty])
    @student_task.task_start_date = DateTime.now
    
    #@student_team = StudentTeam.find_by(id: params[:student_team_id])
    if @student_task.save
      redirect_to student_team_dashboard_path(@student_task.student_team_id), notice: 'Task was successfully created'
    else
      #Need to add something to notify of error
      redirect_to student_team_dashboard_path(@student_task.student_team_id), notice: 'Task creation failed'
    end
  end

  # PATCH/PUT /uni_modules/1
  def update
    @student_task = StudentTask.find_by(id:params[:id])
    puts(student_task_edit_params[:student_task][:student_task_edit][:edit_reason])
    # edit_reason = student_task_edit_params[:student_task_edits][:edit_reason]
    @student_task.student_task_edits.build(previous_target_date: @student_task.task_target_date)
    #@student_task.student_task_edits.build
    # @task_edit = @student_task.student_task_edits.build(previous_target_date: @student_task.task_target_date)
    # @student_task.task_target_date = student_task_params[:task_target_date]
    # @student_task.task_objective = student_task_params[:task_objective]
    # @student_task.task_difficulty = StudentTask.difficulty_string_to_int(student_task_params[:task_difficulty])
    if(@student_task.update(student_task_edit_params))
      # @task_edit.edit_reason = student_task_params[:student_task_edit_attributes][:edit_reason]
      # @task_edit.save
      redirect_to student_task_path(@student_task), notice: 'Task was updated created'
    else
      #Need to add something to notify of error
      redirect_to student_task_path(@student_task), notice: 'Task update failed'
    end
  end

  # DELETE /uni_modules/1
  def destroy

  end

  # DELETE /uni_modules/1
  def comment
    @comment = StudentTaskComment.new(comment_params)
    @comment.user_id = current_user.id
    @comment.student_task_id = params[:student_task_id]
    @comment.posted_on = DateTime.now
    @student_task = StudentTask.find_by(id: params[:student_task_id])
    if @comment.save
      @comment_outcome = "Comment posted"
      redirect_to student_task_path(@student_task), notice: 'Comment posted'
    else
      #Need to add something to notify of error
      @comment_outcome = "Comment failed to post"
      redirect_to student_task_path(@student_task), notice: 'Comment failed'
    end
    respond_to do |format|
      format.js
    end
  end

  def delete_comment
    @comment = StudentTaskComment.find_by(id: params[:id])
    @student_task = StudentTask.find_by(id: @comment.student_task_id)
    @comment.destroy
    respond_to do |format|
      format.js
    end
  end

  # DELETE /uni_modules/1
  def like_task
    @student_task = StudentTask.find_by(params[:student_task_id])
    @task_id = params[:student_task_id]
    @like_id = ("#like-button"+ params[:student_task_id].to_s)
    puts(@like_id)
    if (StudentTaskLike.where(user_id: current_user.id ,student_task_id: params[:student_task_id]).exists?)
      @like = StudentTaskLike.find_by(user_id: current_user.id ,student_task_id: params[:student_task_id])
      @like.destroy
      @like_outcome = "LIKE"
    else
      @like = StudentTaskLike.create(user_id: current_user.id, student_task_id: params[:student_task_id])
      @like_outcome = "UNLIKE"
    end
    respond_to do |format|
      format.js
    end
  end

  def return_task_list
    @student_team = StudentTeam.find_by(id: params[:student_team_id])
    @task = StudentTask.new
    @select_options = StudentTeam.createTeamArray(params[:student_team_id], @student_team.team_id)
    respond_to do |format|
      format.js
    end
  end

  def complete
    @student_task = StudentTask.find_by(id: params[:student_task_id])
    puts(complete_params[:hours])
    puts(complete_params[:task_completed_summary])
    @student_task.hours = complete_params[:hours].to_i
    @student_task.task_completed_summary = complete_params[:task_completed_summary]
    puts(@student_task.inspect)
    if(@student_task.update(complete_params))
      @student_task.task_complete_date = DateTime.now
      @student_task.save
      puts("Success!!!")
      render 'task_complete_success'
    else
      puts(@student_task.errors.full_messages)
      render 'task_complete_failure'
    end
  end




  private
    # Use callbacks to share common setup or constraints between actions.


    #Only allow a list of trusted parameters through.
    def student_task_params
      params.require(:student_task).permit(:task_objective, :task_difficulty, :task_target_date, :student_team_id)
    end

    def student_task_edit_params
      params.require(:student_task).permit(:task_objective, :task_difficulty, :task_target_date, :student_team_id, student_task_edits_attributes: [:id, :edit_reason, :_destroy])
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
