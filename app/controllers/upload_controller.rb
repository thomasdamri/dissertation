require 'tsv'
class UploadController < ApplicationController
  before_action :authenticate_user!
  # No model associated with this controller - no cancancan check
  skip_authorization_check

  def upload_grades
    @title = "Upload Team Grades"
    @assessment_id = params[:id]
  end

  def process_grades
    # Check assessment id is valid
    if params[:assess_id].nil?
      redirect_to upload_grades_path, notice: 'There was an error, please try again'
      return
    end

    # Check file was selected
    if params['file'].nil?
      redirect_to upload_grades_path, notice: 'No file was selected'
      return
    end

    # Check assessment exists
    assessment = Assessment.find(params[:assess_id].to_i)
    if assessment.nil?
      redirect_to upload_grades_path, notice: 'There was an error, please try again'
    end

    mod = assessment.uni_module
    csv_contents = params['file'].read()

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

  def delete_grades
    # Find the assessment from the parameters
    assess_id = params[:id]
    assess = Assessment.find(assess_id)

    # Delete all team grades associated with this assessment
    assess.team_grades.each do |tg|
      tg.destroy
    end

    # Send user back to the module page
    redirect_to assess, notice: 'Team grades were successfully deleted'
  end

end
