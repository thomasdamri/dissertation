class StudentTasksController < ApplicationController

  before_action :authenticate_user!
  authorize_resource

  # GET /uni_modules/1
  def show
    @student_task = StudentTask.find_by(id: params[:id])
    @student_task_comment = StudentTaskComment.new
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
    puts(@comment.inspect)
    @student_task = StudentTask.find_by(id: params[:student_task_id])
    if @comment.save
      redirect_to student_task_path(@student_task), notice: 'Comment posted'
    else
      #Need to add something to notify of error
      redirect_to student_task_path(@student_task), notice: 'Comment failed'
    end
  end

  def delete_comment
    @comment = StudentTaskComment.find_by(id: params[:id])
    @student_task = StudentTask.find_by(id: @comment.student_task_id)
    @comment.destroy
    redirect_to student_task_path(@student_task), notice: 'Comment posted'
  end

  # DELETE /uni_modules/1
  def like_task
    if (StudentTaskLike.where(user_id: current_user.id ,student_task_id: params[:student_task_id]).exists?)
      @like = StudentTaskLike.find_by(user_id: current_user.id ,student_task_id: params[:student_task_id])
      puts(@like.inspect)
      @like.destroy
      puts("UNLIKED")
    else
      @like = StudentTaskLike.create(user_id: current_user.id, student_task_id: params[:student_task_id])
      puts("LIKED")
    end
    redirect_to student_task_path(params[:student_task_id])
  end

  def return_task_list

    @student_team = StudentTeam.find_by(id: params[:student_team_id])
    respond_to do |format|
      format.js
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
      params.require(:student_task_comment).permit(:comment)
    end



end
