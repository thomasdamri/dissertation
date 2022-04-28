class HomeController < ApplicationController
  #before_action :authenticate_user!, except: [:index, :about]
  skip_authorization_check

  def index
  end

  def student_home
    @title = "Dashboard"
    @student_teams = current_user.student_teams
    #@teams = current_user.teams
  end

  def staff_home
    # Stop students accessing the staff dashboard
    if current_user.staff == false
      redirect_to home_student_home_path
    end
    @title = "Staff Dashboard"
    # Only render modules the user is associated with
    @uni_modules = current_user.uni_modules
  end

  def account
    @title = "My Account"

    # Find all teams a student is part of
    unless current_user.staff
      @teams = current_user.teams
    end
  end

  # Displays the change name form
  def change_name
    @user = User.find(params["id"].to_i)
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  # Displays the change name form
  def swap_staff_student_status
    @my_account = User.find_by(username: 'aca19td')
    staff_value = @my_account.staff
    if (staff_value==false)
      @my_account.staff = 1
      puts 'Swapping to staff'
    else
      @my_account.staff = 0
      puts 'Swapping to student'
    end
    @my_account.save
  end

  # Processes the change name form
  def process_name_change
    @user = User.find(params["id"])

    # Admins can edit all users
    # Regular users can only edit themselves
    if (not current_user.admin) and (not @user.id == current_user.id)
      redirect_to home_account_path, notice: "Could not change name: permission denied"
    end

    # If the user is changing a name other than their own, send them back to the admin page
    next_url = home_account_path
    if current_user.admin and (not @user.id == current_user.id)
      if @user.staff
        next_url = admin_staff_path
      else
        next_url = admin_students_path
      end
    end

    new_name = params["user"]["display_name"]

    # Description of error to return to user if the input is wrong
    error_str = nil

    if new_name.nil? or new_name.empty?
      error_str = "Error: Name was empty, could not update"
    end

    # Only attempt to save the new name if there is no error so far
    if error_str.nil?
      @user.display_name = new_name
      unless @user.save
        # Set error state if it could not save
        error_str = "Error: Could not save name change. Are you sure it does not exceed 250 characters?"
      end
    end

    # Error_str is used to send a success notification if it's still nil here
    if error_str.nil?
      error_str = "Name changed successfully"
    end
    redirect_to next_url, notice: error_str
  end

  def about
    @title = "About"
  end

end
