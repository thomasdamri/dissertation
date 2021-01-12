class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_check
  # No resource associated with this controller, cancancan shouldnt authorize
  skip_authorization_check

  # Checks if the current user is an admin, if not a 404 page is displayed
  def admin_check
    if current_user.nil?
      raise ActionController::RoutingError.new("Not Found")
    end
    unless current_user.admin
      raise ActionController::RoutingError.new("Not Found")
    end
  end

  # List of all students
  def students
    @title = "Admin Students List"
    @users = User.where(staff: false)
  end

  # List of all staff
  def staff
    @title = "Admin Staff List"
    @users = User.where(staff: true)
  end

  # List of all modules
  def modules
    @title = "Admin Modules List"
    @uni_modules = UniModule.all
  end

  # List of all teams
  def teams
    @title = "Admin Teams List"
    @teams = Team.order(:uni_module_id, :number)
  end

  # Path for making the current user a staff member
  def make_staff
    current_user.staff = true
    current_user.save
    redirect_to '/'
  end

  # Path for making the current user a student
  def make_student
    current_user.staff = false
    current_user.save
    redirect_to '/'
  end

end
