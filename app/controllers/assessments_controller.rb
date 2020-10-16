class AssessmentsController < ApplicationController
  before_action :set_assessment, only: [:show, :edit, :update, :destroy]

  include ERB::Util

  # GET /assessments
  # GET /assessments.json
  def index
    @assessments = Assessment.all
  end

  # GET /assessments/1
  # GET /assessments/1.json
  def show
  end

  # GET /assessments/new
  def new
    @assessment = Assessment.new
    @unimod = UniModule.find(params[:id].to_i)
  end

  # GET /assessments/1/edit
  def edit
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
      # Manually set criteria min/max values if a boolean
      if crit.response_type == Criterium.bool_type
        crit.max_value = 1
        crit.max_value = 0
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
    @assessment = Assessment.find(params[:id])

  end

  # Processes the form for students filling in the assessment
  def process_assess
    # Find the assessment being filled in
    assessment = Assessment.find(params[:id])
    team = current_user.teams.where(uni_module_id: assessment.uni_module.id).first
    # Loop through each criteria and create a new response
    assessment.criteria.order(:order).each do |crit|
      # Escape the response before storing in database
      response = h params["response_#{crit.order}"]
      AssessmentResult.create(author: current_user, target: User.first, criterium: crit, value: response)
    end

    redirect_to team

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assessment
      @assessment = Assessment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def assessment_params
      params.require(:assessment).permit(:name, :date_opened, :date_closed, :mod,
                                         criteria_attributes: [:title, :order, :response_type, :min_value, :max_value])
    end
end
