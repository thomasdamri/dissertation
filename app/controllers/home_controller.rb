class HomeController < ApplicationController
  def index
  end

  def student_home

  end

  def staff_home
    # Only render modules the user is associated with
    @uni_modules = current_user.uni_modules
  end

  def account

  end

end
