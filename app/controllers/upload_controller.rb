class UploadController < ApplicationController

  include ERB::Util

  # Path for uploading a CSV file of user info
  def upload_users

  end

  # POST upload/process
  # Processes the CSV file of new users
  def user_process

    # Check file exists first
    if params['file'].nil?
      redirect_to upload_teams_path, notice: 'No file was selected'
    else
      # Read file
      csv_content = params['file'].read

      # Split by line
      csv_content.split("\n").each do |line|
        # Escape html on line
        line = h line

        # Split each line by comma to get each user attribute
        user_attr = line.split(',')

        # Attempt to create a user given the attributes
        # Validations in the model file prevent the same user being added twice
        u = User.create(givenname: user_attr[0], sn: user_attr[1], username: user_attr[2], reg_no: user_attr[3],
                        email: user_attr[4], staff: false, admin: false)
      end
      redirect_to home_staff_home_path
    end
  end

  def upload_teams
    @mod_id = params[:id]

  end

  def team_process
    # Check module id is valid
    if params[:mod_id].nil?
      redirect_to upload_teams_path, notice: 'There was an error, please try again'
    end

    # Check file was selected
    if params['file'].nil?
      redirect_to upload_teams_path, notice: 'No file was selected'
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

end
