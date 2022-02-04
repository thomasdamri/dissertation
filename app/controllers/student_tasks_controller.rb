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

    # # Text for the submit button if module is not valid
    # @btn_text = "Create"

    # if @uni_module.save
    #   @uni_module.ensure_mondays
    #   redirect_to @uni_module, notice: 'Module was successfully created.'
    # else
    #   render :new
    # end
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

    # Only allow a list of trusted parameters through.
    # def uni_module_params
    #   params.require(:student_task).permit(:name, :code, :start_date, :end_date,
    #                                      staff_modules_attributes: [:id, :user_id, :_destroy])
    # end

end
