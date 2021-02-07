class AssessmentsController < ApplicationController
  before_action :set_assessment, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  load_and_authorize_resource

  include ERB::Util
  require 'tsv'
  require 'csv'

  # GET /assessments/1
  def show
    @title = "Viewing Assessment"
    @num_crits = @assessment.criteria.count
    @assessed_crits = @assessment.criteria.where(assessed: true).count
    @teams = @assessment.uni_module.teams
  end

  # GET /assessments/new
  def new
    @title = "Create Assessment"
    @assessment = Assessment.new
    @unimod = UniModule.find(params[:id].to_i)
    # Check the user is a member of this module
    unless @unimod.staff_modules.pluck(:user_id).include? current_user.id
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  # POST /assessments
  def create
    @assessment = Assessment.new(assessment_params)
    @unimod = UniModule.find(params[:assessment][:mod])

    # Set parent module
    @assessment.uni_module = @unimod

    # Set the criteria min/max values to nil if response type is a string
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

    if @assessment.save
      redirect_to @assessment, notice: 'Assessment was successfully created.'
    else
      render :new
    end
  end

  # DELETE /assessments/1
  def destroy
    # Save uni_module for redirect later
    unimod = @assessment.uni_module
    @assessment.destroy
    redirect_to unimod, notice: 'Assessment was successfully destroyed.'
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

    # Create a transaction. The responses should only save if they are all valid
    ActiveRecord::Base.transaction do
      # Loop through each criteria and create a new response
      assessment.criteria.each do |crit|
        # For single response criteria, just save one new result
        if crit.single
          # Escape the response before storing in database
          response = h params["response_#{crit.id}"]
          AssessmentResult.create!(author: current_user, criterium: crit, value: response)
        else
          # For multi-response criteria, store each one for each user
          team.users.each do |user|
            response = h params["response_#{crit.id}_#{user.id}"]
            AssessmentResult.create!(author: current_user, target: user, criterium: crit, value: response)
          end
        end
      end

      assessment.generate_weightings(team)

    end

    # Return user to the team overview page after completion
    redirect_to team

  # Prevent an error page being shown to the user, send back to fill in page
  rescue ActiveRecord::RecordInvalid
    @team = team
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

    @team = current_user.teams.where(uni_module: @assessment.uni_module).first
    tg = TeamGrade.where(team: @team, assessment: @assessment).first
    @team_grade = tg.nil? ? "Grade not given yet" : tg.grade
    @weighting = @stud_weight.nil? ? "Weighting not given yet" : @stud_weight.weighting.round(2)

    @personal_grade = ""
    if tg.nil? or @stud_weight.nil?
      @personal_grade = "Grade not given yet"
    else
      @personal_grade = (@stud_weight.weighting.to_f * @team_grade.to_f).round(2)
    end

    respond_to do |format|
      format.js {render layout: false}
    end
    
  end


  # Exports each student's grades to a CSV file
  def csv_export
    # Find the assessment to export data from
    assessment = Assessment.find(params['id'])
    # Generate the CSV file as a string first
    csv_str = CSV.generate headers: true do |csv|
      csv << ["Student Username", "Team Number", "Team Grade", "Individual Weighting", "Individual Grade"]
      assessment.uni_module.teams.each do |team|
        team.users.each do |user|
          # Try to find the team's grade
          t_grade = team.team_grades.where(assessment_id: assessment.id).first
          team_grade = t_grade.nil? ? "NULL" : t_grade.grade

          # Try to find user's individual weighting
          weight = user.student_weightings.where(assessment_id: assessment).first
          ind_weight = weight.nil? ? "NULL" : weight.weighting

          # Only calculate an individual grade if both team grade and indiv. weighting exist
          ind_grade = "NULL"
          unless t_grade.nil? or weight.nil?
            ind_grade = team_grade * ind_weight
          end

          csv << [user.username, team.number, team_grade, ind_weight, ind_grade]
        end
      end
    end

    # Return the CSV file to the user as a download
    respond_to do |format|
      format.csv {send_data csv_str, filename: "Export-Assessment-#{Date.today}.csv", disposition: 'attachment',
                            type: 'text/csv'}
    end

  end


  # Tells the StudentMailer to email out grades
  def send_score_email
    assessment = Assessment.find(params['id'])
    teams = assessment.uni_module.teams.pluck(:id)
    stud_teams = StudentTeam.where(team_id: teams).pluck(:user_id)
    users = User.where(id: stud_teams).all

    users.each do |u|
      team = u.teams.where(uni_module: assessment.uni_module).first
      team_grade = team.team_grades.where(assessment: assessment).first
      ind_weight = StudentWeighting.where(user: u, assessment: assessment).first

      # Only send the email to the student if they have a team grade and an individual weighting
      unless team_grade.nil? or ind_weight.nil?
        StudentMailer.score_email(u, assessment, team_grade, ind_weight).deliver
      end
    end

    redirect_to assessment, notice: "Emails sent successfully"
  end

  # AJAX call to render a modal with the individual responses to each criteria
  def get_ind_responses
    @assessment = Assessment.find(params['id'])
    @team = Team.find(params['team_id'])

    respond_to do |format|
      format.js {render layout: false}
    end

  end

  # AJAX request for rendering modal for uploading team grades as a csv
  def upload_grades
    @assessment_id = params[:id]

    respond_to do |format|
      format.js {render layout: false}
    end
  end

  # Processes the form submitted to :upload_grades
  def process_grades
    # Check assessment id is valid
    if params[:assess_id].nil?
      redirect_to home_staff_home_path, notice: 'There was an error, please try again'
      return
    end

    # Check assessment exists
    assessment = Assessment.where(id: params[:assess_id].to_i).first
    if assessment.nil?
      redirect_to home_staff_home_path, notice: 'There was an error, please try again'
    end

    # Check file was selected
    if params['file'].nil?
      redirect_to assessment_path(assessment), notice: "Upload failed. Please attach a file before attempting upload"
      return
    end

    mod = assessment.uni_module
    csv_contents = params['file'].read

    # Read in each line of the CSV
    csv_contents.split("\n").each do |line|
      # Escape HTML before processing
      line = h line
      grade_attr = line.split(",")
      # Find team
      t = Team.where(uni_module: mod, number: grade_attr[0]).first
      # Attach grade to the team
      t.team_grades.create(team_id: t.id, assessment_id: assessment.id, grade: grade_attr[1])
    end

    redirect_to assessment

  end

  # Removes all team grades for an assessment
  def delete_grades
    # Find the assessment from the parameters
    assess_id = params[:id]
    assess = Assessment.where(id: assess_id).first
    if assess.nil?
      return redirect_to home_staff_home_path, notice: 'There was an error, please try again'
    end

    # Delete all team grades associated with this assessment
    assess.team_grades.each do |tg|
      tg.destroy
    end

    # Send user back to the assessment page
    redirect_to assess, notice: 'Team grades were successfully deleted'
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
                                                               :single, :assessed, :weighting, :_destroy])
    end
end
