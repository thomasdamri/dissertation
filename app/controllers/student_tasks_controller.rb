class StudentTasksController < ApplicationController
  #before_action :set_uni_module, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  load_and_authorize_resource

  # GET /uni_modules/1
  def show

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
  end

  # POST /uni_modules
  def create
    @student_task = StudentTask.new(student_task_params)
    @student_task.student_team_id = params[:student_team_id]
    @student_team = StudentTeam.find_by(params[:student_team_id])
    if @student_task.save
      redirect_to student_team_dashboard_path(@student_team.id), notice: 'Task was successfully created'
    else
      #Need to add something to notify of error
      redirect_to student_team_dashboard_path(@student_team.id), notice: 'Task was successfully created'
    end
  end

  # PATCH/PUT /uni_modules/1
  def update

  end

  # DELETE /uni_modules/1
  def destroy
    # @student_task.destroy
    # redirect_to home_staff_home_path, notice: 'Uni module was successfully destroyed.'
  end





  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_uni_module
    #   @uni_module = UniModule.find(params[:id])
    # end

    #Only allow a list of trusted parameters through.
    def student_task_params
      params.require(:student_task).permit(:task_objective, :task_difficulty, :task_target_date, :student_team_id)
    end

end
