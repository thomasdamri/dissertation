require 'tsv'
class UploadController < ApplicationController
  before_action :authenticate_user!
  # No model associated with this controller - no cancancan check
  skip_authorization_check

  include ERB::Util

  # Path for uploading a CSV file of user info
  def upload_users
    @title = "Upload User CSV"
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
    @title = "Team Assignment Upload"
    @mod_id = params[:id]
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
      line = h line
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

  # Deletes all teams that are part of that module
  def delete_teams
    mod_id = params[:id]
    mod = UniModule.find(mod_id)

    mod.teams.each do |team|
      team.delete
    end

    redirect_to mod, notice: 'Teams were successfully deleted'

  end

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
