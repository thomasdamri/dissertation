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

    # Find all modules a student participates in
    unless current_user.staff
      @uni_modules = UniModule.where(id: current_user.teams.pluck(:uni_module_id))
    end
  end

  def about
    @title = "About"
  end

end
