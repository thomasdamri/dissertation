class HomeController < ApplicationController
  def index
  end

  def student_home
    @title = "Dashboard"
  end

  def staff_home
    @title = "Staff Dashboard"
    # Only render modules the user is associated with
    @uni_modules = current_user.uni_modules
  end

  def account
    @title = "My Account"
  end

end
