class TeamsController < ApplicationController
  before_action :set_team, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  load_and_authorize_resource

  # GET /teams
  # GET /teams.json
  def index
    @teams = Team.all
  end

  # GET /teams/1
  # GET /teams/1.json
  def show
    @title = "Team #{@team.number}"
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
  # POST /teams.json
  def create
    @team = Team.new(team_params)

    respond_to do |format|
      if @team.save
        format.html { redirect_to @team, notice: 'Team was successfully created.' }
        format.json { render :show, status: :created, location: @team }
      else
        format.html { render :new }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /teams/1
  # PATCH/PUT /teams/1.json
  def update
    respond_to do |format|
      if @team.update(team_params)
        format.html { redirect_to @team, notice: 'Team was successfully updated.' }
        format.json { render :show, status: :ok, location: @team }
      else
        format.html { render :edit }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /teams/1
  # DELETE /teams/1.json
  def destroy
    @team.destroy
    respond_to do |format|
      format.html { redirect_to teams_url, notice: 'Team was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def grade_form
    @title = "Set Team Grade"
    @team = Team.find(params[:id])
    @assessment = Assessment.find(params[:assess])
    render 'teams/grade_form'
  end

  # Sets the team's grade for an assignment
  def set_grade
    @team = Team.find(params[:team_id])
    @assessment = Assessment.find(params[:assessment_id])

    tg = TeamGrade.find_or_initialize_by(team: @team, assessment: @assessment)
    tg.grade = params[:new_grade]
    tg.save!

    redirect_to @team, notice: "Team grade set successfully"

  end

  # GET '/teams/:id/:assess/view_ind_grades' (AJAX)
  # Sends all the individual grades for the team and assessment given as AJAX data
  def view_ind_grades
    team = Team.find(params['id'])
    assessment = Assessment.find(params['assess'])
    @team_grade = TeamGrade.where(team_id: team.id, assessment_id: assessment.id).first

    @ind_weights = StudentWeighting.where(user: team.users, assessment: assessment)

    respond_to do |format|
      format.js { render layout: false }
    end

  end

  # POST /teams/:id/:assess/update_ind_grades
  # Updates all the individual grades for the team and assessment
  def update_ind_grades
    team = Team.find(params['id'])
    assessment = Assessment.find(params['assess'])

    # Find all the ids of student weightings for this team and assessment
    stud_weights = StudentWeighting.where(assessment: assessment, user: team.users)

    # Checks if there was at least one grade reset when checking all student weightings
    did_reset = false

    stud_weights.each do |sw|
      # Check if this weighting needs manually setting
      new_weight = params["new_weight_#{sw.id}"]
      unless new_weight.nil? or new_weight == ""
        sw.manual_update new_weight
      end

      # Check if this weighting needs resetting
      should_reset = params["reset_check_#{sw.id}"]
      if should_reset == "on"
        did_reset = true
        sw.manual_set = false
        sw.save
      end

    end

    # Re-generate the peer assessment scores if there was a reset
    if did_reset
      assessment.generate_weightings team
    end

    redirect_to team
  end

  def reset_ind_grade
    stud_weight = StudentWeighting.find(params['sw_id'])
    team = Team.find(params['id'])

    stud_weight.manual_set = false
    stud_weight.save

    stud_weight.assessment

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
