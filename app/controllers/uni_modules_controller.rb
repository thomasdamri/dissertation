class UniModulesController < ApplicationController
  before_action :set_uni_module, only: [:show, :edit, :update, :destroy]

  # GET /uni_modules
  # GET /uni_modules.json
  def index
    @uni_modules = UniModule.all
  end

  # GET /uni_modules/1
  # GET /uni_modules/1.json
  def show
    @title = @uni_module.name
    @teams = @uni_module.teams
    @students = User.where(id: StudentTeam.where(team_id: @teams.pluck(:id)).pluck(:user_id)).count
  end

  # GET /uni_modules/new
  def new
    @title = "Creating Module"
    @uni_module = UniModule.new
  end

  # GET /uni_modules/1/edit
  def edit
    @title = "Editing Module"
  end

  # POST /uni_modules
  # POST /uni_modules.json
  def create
    @uni_module = UniModule.new(uni_module_params)

    # Link the current user to the module so they have permission to edit it
    @uni_module.staff_modules.build(user: current_user)

    respond_to do |format|
      if @uni_module.save
        format.html { redirect_to @uni_module, notice: 'Module was successfully created.' }
        format.json { render :show, status: :created, location: @uni_module }
      else
        format.html { render :new }
        format.json { render json: @uni_module.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /uni_modules/1
  # PATCH/PUT /uni_modules/1.json
  def update

    # Can only validate this in edit mode, as in create mode the user link is not saved until after validation
    if @uni_module.staff_modules.length < 1
      @uni_module.errors[:staff_modules] << " must have at least one member of staff"
    end

    respond_to do |format|
      if @uni_module.update(uni_module_params)
        format.html { redirect_to @uni_module, notice: 'Uni module was successfully updated.' }
        format.json { render :show, status: :ok, location: @uni_module }
      else
        format.html { render :edit }
        format.json { render json: @uni_module.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /uni_modules/1
  # DELETE /uni_modules/1.json
  def destroy
    @uni_module.destroy
    respond_to do |format|
      format.html { redirect_to uni_modules_url, notice: 'Uni module was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_uni_module
      @uni_module = UniModule.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def uni_module_params
      params.require(:uni_module).permit(:name, :code, staff_modules_attributes: [:id, :user_id, :_destroy])
    end
end
