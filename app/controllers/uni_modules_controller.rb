class UniModulesController < ApplicationController
  before_action :set_uni_module, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  load_and_authorize_resource

  # GET /uni_modules/1
  def show
    max_staff_shown = 6

    @title = @uni_module.name
    @teams = @uni_module.teams
    @students = User.where(id: StudentTeam.where(team_id: @teams.pluck(:id)).pluck(:user_id)).count

    @show_all = @uni_module.staff_modules.count > max_staff_shown
    @staff_list = @uni_module.staff_modules.first(max_staff_shown)

    if @staff_list.nil?
      @staff_list = []
    end
  end

  # GET /uni_modules/new
  def new
    @title = "Creating Module"
    @uni_module = UniModule.new
    @btn_text = "Create"

    # Link the current user to the module so they have permission to edit it
    @uni_module.staff_modules.build(user: current_user)
  end

  # GET /uni_modules/1/edit
  def edit
    @title = "Editing Module"
    @btn_text = "Update"
  end

  # POST /uni_modules
  def create
    @uni_module = UniModule.new(uni_module_params)

    # Text for the submit button if module is not valid
    @btn_text = "Create"

    if @uni_module.save
      @uni_module.ensure_mondays
      redirect_to @uni_module, notice: 'Module was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /uni_modules/1
  def update
    # Ensure that the number of removed staff members does not exceed the number of total staff members
    net_deleted = 0
    params["uni_module"]["staff_modules_attributes"].each do |i, sm|
      if sm["_destroy"] == "1"
        net_deleted += 1
      else
        net_deleted -= 1
      end
    end

    # Text for submission button if form fails to save
    @btn_text = "Update"

    # If the number of net deletions equals the number of existing staff, no more staff are on the module
    if net_deleted == @uni_module.staff_modules.length
      return render :edit
    end

    if @uni_module.update(uni_module_params)
      @uni_module.ensure_mondays
      redirect_to @uni_module, notice: 'Uni module was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /uni_modules/1
  def destroy
    @uni_module.destroy
    redirect_to home_staff_home_path, notice: 'Uni module was successfully destroyed.'
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
      redirect_to home_staff_home_path, alert: "Upload failed. Please attach a file before attempting upload"
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

  # AJAX request for uploading a team assignment CSV
  def upload_teams
    @mod_id = params[:id]
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  # Processes a team assignment CSV and adds the specified StudentTeam objects
  def team_process
    # Check module id is valid
    if params[:mod_id].nil?
      redirect_to home_staff_home_path, notice: 'There was an error, please try again'
      return
    end

    # Check module exists
    mod = UniModule.where(id: params[:mod_id].to_i).first
    if mod.nil?
      redirect_to home_staff_home_path, notice: 'There was an error, please try again'
    end

    # Check file was selected
    if params['file'].nil?
      redirect_to uni_module_path(mod), notice: "Upload failed. Please attach a file before attempting upload"
      return
    end

    csv_contents = params['file'].read()

    csv_contents.split("\n").each do |line|
      # Escape HTML before processing
      line = line
      team_attr = line.split(",")
      username = team_attr[0]

      # Find user
      u = User.find_by_username(team_attr[0])
      # Find team, or create it if it doesnt already exist
      t = Team.find_or_create_by(uni_module: mod, team_number: team_attr[1])
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


  # Shows all staff in a module if there are more than can be shown
  def show_all_staff
    @uni_module = UniModule.find(params["id"])
    @staff_list = @uni_module.staff_modules

    respond_to do |format|
      format.js {render layout: false}
    end
  end


  # AJAX call for displaying all students on a module sorted by team
  def show_all_students
    @uni_module = UniModule.find(params["id"])

    respond_to do |format|
      format.js {render layout: false}
    end
  end

  # This method is better in UniModules controller for CanCanCan reasons
  # Page to display all disputes for a module
  def view_disputes
    @uni_module = UniModule.find(params['id'])
    # Hash holds each team's disputed worklogs by their team id (if any exist)
    @logs = {}
    # Hash holds each disputed worklog's responses, accessible by the worklog's id
    @disputes = {}

    # Find the disputes for each worklog for each team
    @uni_module.teams.each do |team|
      logs = Worklog.where(author: team.users, uni_module: @uni_module).order(:fill_date)
      unless logs.count == 0
        disputes = WorklogResponse.where(worklog: logs, status: WorklogResponse.reject_status)
        unless disputes.count == 0
          # Get the ids of all worklogs with a dispute
          disputed_log_ids = disputes.pluck(:worklog_id)
          @logs[team.id] = Worklog.where(id: disputed_log_ids)
          logs.each do |log|
            log_disputes = disputes.where(worklog: log)
            unless log_disputes.count == 0
              @disputes[log.id] = log_disputes
            end
          end
        end
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_uni_module
      @uni_module = UniModule.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def uni_module_params
      params.require(:uni_module).permit(:name, :code, :start_date, :end_date,
                                         staff_modules_attributes: [:id, :user_id, :_destroy])
    end
end
