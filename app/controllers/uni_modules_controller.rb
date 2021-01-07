class UniModulesController < ApplicationController
  before_action :set_uni_module, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  load_and_authorize_resource

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

  # AJAX path for uploading a CSV file of user info
  def upload_users
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  # POST upload/process
  # Processes the TSV file of new users
  def user_process
    # Check file exists first
    if params['file'].nil?
      redirect_to upload_teams_path, notice: 'Error: No file was selected'
    else
      count_before = User.count
      # Read the file into a TSV object
      tsv_file = TSV.parse(params['file'].read)

      # Extract the user info from each row of the tsv file
      tsv_file.each do |row|
        reg_no = row["Reg No."]
        username = row["Student Username"]
        surname = row["Surname"]
        firstname = row["Forename"]
        email = row["Email"]

        User.create(reg_no: reg_no, username: username, sn: surname, givenname: firstname, email: email,
                    staff: false, admin: false)
      end

      count = User.count - count_before
      redirect_to home_staff_home_path, notice: "Successfully added #{count} students"

    end
  end

  def upload_teams
    @mod_id = params[:id]
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def team_process
    # Check module id is valid
    if params[:mod_id].nil?
      redirect_to upload_teams_path, notice: 'There was an error, please try again'
      return
    end

    # Check file was selected
    if params['file'].nil?
      redirect_to upload_teams_path, notice: 'No file was selected'
      return
    end

    # Check module exists
    mod = UniModule.find(params[:mod_id].to_i)
    if mod.nil?
      redirect_to upload_teams_path, notice: 'There was an error, please try again'
    end

    csv_contents = params['file'].read()

    csv_contents.split("\n").each do |line|
      # Escape HTML before processing
      line = line
      team_attr = line.split(",")
      # Find user
      u = User.find_by_username(team_attr[0])
      # Find team, or create it if it doesnt already exist
      t = Team.find_or_create_by(uni_module: mod, number: team_attr[1])
      # Attach student to the team
      u.student_teams.create(user: u, team: t)
    end

    redirect_to uni_module_path mod

  end

  # Deletes all teams that are part of the module
  def delete_teams
    mod_id = params[:id]
    mod = UniModule.find(mod_id)

    mod.teams.each do |team|
      team.delete
    end

    redirect_to mod, notice: 'Teams were successfully deleted'

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
