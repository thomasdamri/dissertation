class HomeController < ApplicationController
  before_action :authenticate_user!, except: [:index, :about]
  skip_authorization_check

  def index
  end

  def student_home
    @title = "Dashboard"

    @current_assess = []
    @completed_assess = []
    my_assess = Assessment.where(uni_module: UniModule.where(teams: current_user.teams))

    my_assess.each do |assess|
      if assess.date_closed.past?
        @completed_assess << assess
      else
        @current_assess << assess
      end
    end

  end

  def staff_home
    @title = "Staff Dashboard"
    # Only render modules the user is associated with
    @uni_modules = current_user.uni_modules
  end

  def account
    @title = "My Account"
  end

  def about
    @title = "About"
  end

end
