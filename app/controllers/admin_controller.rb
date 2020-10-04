class AdminController < ApplicationController

  def students
    @users = User.where(staff: false)
  end

  def staff
    @users = User.where(staff: true)
  end

  def modules
    @uni_modules = UniModule.all
    render 'uni_modules/index'
  end

  def teams
    @teams = Team.order(:uni_module_id, :number)
  end

end
