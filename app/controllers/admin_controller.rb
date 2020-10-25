class AdminController < ApplicationController

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

end
