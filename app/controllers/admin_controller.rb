class AdminController < ApplicationController
  before_action :authenticate_user!
  # No resource associated with this controller, cancancan shouldnt authorize
  skip_authorization_check

  def students
    @title = "Admin Students List"
    @users = User.where(staff: false)
  end

  def staff
    @title = "Admin Staff List"
    @users = User.where(staff: true)
  end

  def modules
    @title = "Admin Modules List"
    @uni_modules = UniModule.all
    render 'uni_modules/index'
  end

  def teams
    @title = "Admin Teams List"
    @teams = Team.order(:uni_module_id, :number)
  end

  def make_staff
    current_user.staff = true
    current_user.save
    redirect_to '/'
  end

  def make_student
    current_user.staff = false
    current_user.save
    redirect_to '/'
  end

end
