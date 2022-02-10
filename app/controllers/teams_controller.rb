class TeamsController < ApplicationController
  before_action :set_team, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  load_and_authorize_resource

  # GET /teams/1
  def show
    @title = "Team #{@team.team_number}"
    @users = @team.users
    @assessments = @team.uni_module.assessments
    @team_grades = TeamGrade.where(team: @team)
  end

  # GET /teams/new
  def new
    @team = Team.new
  end

  # GET /teams/1/edit
  def edit
  end

  # POST /teams
  def create
    @team = Team.new(team_params)

    if @team.save
      redirect_to @team, notice: 'Team was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /teams/1
  def update
    if @team.update(team_params)
      redirect_to @team, notice: 'Team was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /teams/1
  def destroy
    @team.destroy
    redirect_to teams_url, notice: 'Team was successfully destroyed.'
  end

  # AJAX request to display a modal for changing a team's grade for an assessment
  def grade_form
    @team = Team.find(params[:id])
    @assessment = Assessment.find(params[:assess])
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  # Sets the team's grade for an assignment
  def set_grade
    @team = Team.find(params[:team_id])
    @assessment = Assessment.find(params[:assessment_id])

    tg = TeamGrade.find_or_initialize_by(team: @team, assessment: @assessment)
    tg.grade = params[:new_grade]
    tg.save!

    redirect_to @assessment, notice: "Team grade set successfully"

  end

  # Work log stuff - makes more sense to be in here, so cancancan can properly authorise based on team

  # AJAX call to display the modal for filling in the worklog for the week
  def new_worklog
    @team = Team.find(params['id'])
    @uni_module = @team.uni_module

    # Check user belongs to the team
    unless @team.users.pluck(:id).include? current_user.id
      redirect_to home_student_home_path, notice: "Error: Invalid team"
    end

    # Check for an existing worklog from this week from this user
    if current_user.has_filled_in_log?(@uni_module)
      return redirect_to @team
    end

    respond_to do |format|
      format.js {render layout: false}
    end
  end

  # Processes the form for filling in a worklog
  def process_worklog
    @team = Team.find(params['id'])
    @uni_module = @team.uni_module

    # Check user belongs to the team
    unless @team.users.pluck(:id).include? current_user.id
      redirect_to home_student_home_path, notice: "Error: Invalid team"
    end

    # Check for an existing worklog from this week from this user
    if current_user.has_filled_in_log?(@uni_module)
      return redirect_to @team
    end

    # Check user actually entered content into the worklog
    if params["content"].nil?
      return redirect_to @team, notice: "Work log content cannot be blank"
    end

    # Create new worklog and ensure fill date is a monday
    wl = Worklog.new(author: current_user, uni_module: @uni_module, fill_date: Date.today, content: params['content'])
    wl.ensure_mondays

    if wl.save
      redirect_to @team, notice: 'Work log uploaded successfully'
    else
      redirect_to @team, notice: "Error uploading worklog"
    end
  end

  # Page for reviewing the past week's worklog
  def review_worklogs
    @title = "Review work logs"
    @team = Team.find(params['id'])
    @date = Date.today.monday? ? Date.today : Date.today.prev_occurring(:monday)
    @logs = Worklog.where(author: @team.users, uni_module: @team.uni_module, fill_date: @date)
  end

  # Page for showing all worklogs for a team
  def display_worklogs
    @title = "Show all work logs"
    @team = Team.find(params['id'])
  end

  # AJAX call for showing a modal of one weeks worth of logs
  def display_log
    @team = Team.find(params['id'])
    @date = @team.uni_module.start_date + (7 * params["weeks"].to_i)

    # Stop date going past module end date
    if @date > @team.uni_module.end_date
      return redirect_to display_worklogs_path(@team), notice: "Error: Invalid date"
    end

    # Find all logs written in the given week by this team
    @logs = Worklog.where(author: @team.users, fill_date: @date, uni_module: @team.uni_module)

    respond_to do |format|
      format.js { render layout: false }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_team
      @team = Team.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def team_params
      params.fetch(:team, {})
    end
end
