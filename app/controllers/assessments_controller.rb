class AssessmentsController < ApplicationController
  before_action :set_assessment, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  include ERB::Util

  # GET /assessments
  # GET /assessments.json
  def index
    @assessments = Assessment.all
  end

  # GET /assessments/1
  # GET /assessments/1.json
  def show
    @title = "Viewing Assessment"
  end

  # GET /assessments/new
  def new
    @title = "Create Assessment"
    @assessment = Assessment.new
    @unimod = UniModule.find(params[:id].to_i)
  end

  # GET /assessments/1/edit
  def edit
    @title = "Edit Assessment"
  end

  # POST /assessments
  # POST /assessments.json
  def create
    @assessment = Assessment.new(assessment_params)
    @unimod = UniModule.find(params[:assessment][:mod])

    # Set parent module
    @assessment.uni_module = @unimod

    # Blank the criteria min/max values if a string
    @assessment.criteria.each do |crit|
      if crit.response_type == Criterium.string_type
        crit.max_value = nil
        crit.min_value = nil
      end

      # Check for empty string in min/max value and make nil
      if crit.min_value == ""
        crit.min_value = nil
      end

      if crit.max_value == ""
        crit.max_value = nil
      end

      # Prevents validation error when assessed is not filled in due to being disabled by the single answer button
      if crit.assessed.nil?
        crit.assessed = false
      end
    end

    respond_to do |format|
      if @assessment.save
        format.html { redirect_to @assessment, notice: 'Assessment was successfully created.' }
        format.json { render :show, status: :created, location: @assessment }
      else
        format.html { render :new }
        format.json { render json: @assessment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /assessments/1
  # PATCH/PUT /assessments/1.json
  def update
    respond_to do |format|
      if @assessment.update(assessment_params)
        format.html { redirect_to @assessment, notice: 'Assessment was successfully updated.' }
        format.json { render :show, status: :ok, location: @assessment }
      else
        format.html { render :edit }
        format.json { render json: @assessment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assessments/1
  # DELETE /assessments/1.json
  def destroy
    @assessment.destroy
    respond_to do |format|
      format.html { redirect_to assessments_url, notice: 'Assessment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # Shows form for user to fill in the assessment
  def fill_in
    @title = "Completing Assessment"
    # Get current assessment, so the server knows which assessment is being filled in
    @assessment = Assessment.find(params[:id])
    # Get the team this assessment is being filled in for
    @team = current_user.teams.where(uni_module_id: @assessment.uni_module.id).first

    # Check user has not already filled in the form
    if @assessment.completed_by? current_user
      redirect_to @team
    end

  end

  # Processes the form for students filling in the assessment
  def process_assess
    # Find the assessment being filled in
    assessment = Assessment.find(params[:id])
    # Find the user's team
    team = current_user.teams.where(uni_module_id: assessment.uni_module.id).first

    # Check user has not already filled in the form
    if assessment.completed_by? current_user
      redirect_to team
    end

    # Find the assessment being filled in


    # Create a transaction. The responses should only save if they are all valid
    ActiveRecord::Base.transaction do
      # Loop through each criteria and create a new response
      assessment.criteria.order(:order).each do |crit|
        # For single response criteria, just save one new result
        if crit.single
          # Escape the response before storing in database
          response = h params["response_#{crit.order}"]
          AssessmentResult.create!(author: current_user, criterium: crit, value: response)
        else
          # For multi-response criteria, store each one for each user
          team.users.each do |user|
            response = h params["response_#{crit.order}_#{user.id}"]
            AssessmentResult.create!(author: current_user, target: user, criterium: crit, value: response)
          end
        end
      end
    end

    # Return user to the team overview page after completion
    redirect_to team

  # Prevent an error page being shown to the user, send back to fill in page
  rescue ActiveRecord::RecordInvalid
    render 'assessments/fill_in'
  end

  # Shows the student their final weighting
  def results
    @assessment = Assessment.find(params[:id])
    @stud_weight = StudentWeighting.where(user: current_user, assessment: @assessment).first

    # If the assessment is not closed yet, or the student has no mark, do not show it
    if (@stud_weight.nil? or (not @assessment.date_closed.past?)) and false
      redirect_to @assessment
    end

    team = current_user.teams.where(uni_module: @assessment.uni_module).first
    tg = TeamGrade.where(team: team, assessment: @assessment).first
    @team_grade = tg.nil? ? "Grade not given yet" : tg.grade
    @weighting = @stud_weight.nil? ? "Weighting not given yet" : @stud_weight.weighting

    @personal_grade = ""
    if tg.nil? or @stud_weight.nil?
      @personal_grade = "Grade not given yet"
    else
      @personal_grade = (@weighting.to_f * @team_grade.to_f).round(2)
    end
    
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assessment
      @assessment = Assessment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def assessment_params
      params.require(:assessment).permit(:name, :date_opened, :date_closed, :mod,
                                         criteria_attributes: [:title, :order, :response_type, :min_value, :max_value,
                                                               :single, :assessed, :weighting])
    end
end
