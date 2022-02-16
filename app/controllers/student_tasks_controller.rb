class StudentTasksController < ApplicationController

  before_action :authenticate_user!
  load_and_authorize_resource

  # GET /uni_modules/1
  def show
    @student_task = StudentTask.find_by(id: params[:id])
    @student_task_comment = StudentTaskComment.new
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
    # render layout: false
  end

  # POST /uni_modules
  def create
    @student_task = StudentTask.new(student_task_params)
    @student_task.student_team_id = params[:student_team_id]
    @student_task.task_difficulty = StudentTask.difficulty_string_to_int(student_task_params[:task_difficulty])
    
    
    #@student_team = StudentTeam.find_by(id: params[:student_team_id])
    if @student_task.save
      redirect_to student_team_dashboard_path(params[:student_team_id]), notice: 'Task was successfully created'
    else
      #Need to add something to notify of error
      redirect_to student_team_dashboard_path(params[:student_team_id]), notice: 'Task creation failed'
    end
  end

  # PATCH/PUT /uni_modules/1
  def update
    @student_task = StudentTask.find_by(id:params[:id])

    if(@student_task.update(student_task_params))
      @student_task.update_attribute(:task_difficulty, StudentTask.difficulty_string_to_int(student_task_params[:task_difficulty]))
      redirect_to student_team_student_task_path(params[:student_team_id], @student_task.id), notice: 'Task was updated created'
    else
      #Need to add something to notify of error
      redirect_to student_team_student_task_path(params[:student_team_id], @student_task.id), notice: 'Task update failed'
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
      redirect_to student_team_student_task_path(@student_task.student_team.id, @student_task.id), notice: 'Comment posted'
    else
      #Need to add something to notify of error
      redirect_to student_team_student_task_path(@student_task.student_team.id, @student_task.id), notice: 'Comment failed'
    end
  end




  private
    # Use callbacks to share common setup or constraints between actions.


    #Only allow a list of trusted parameters through.
    def student_task_params
      params.require(:student_task).permit(:task_objective, :task_difficulty, :task_target_date, :student_team_id)
    end

    #Only allow a list of trusted parameters through.
    def comment_params
      params.require(:student_task_comment).permit(:comment)
    end



end
