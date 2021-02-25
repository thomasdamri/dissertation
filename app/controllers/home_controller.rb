class HomeController < ApplicationController
  before_action :authenticate_user!, except: [:index, :about]
  skip_authorization_check

  def index
  end

  def student_home
    @title = "Dashboard"
    @teams = current_user.teams
  end

  def staff_home
    # Stop students accessing the staff dashboard
    if current_user.staff == false
      redirect_to home_student_home_path
    end
    @title = "Staff Dashboard"
    # Only render modules the user is associated with
    @uni_modules = current_user.uni_modules

    @team_disputes = {}
    my_teams = Team.where(uni_module: @uni_modules)
    my_teams.each do |team|
      # Find disputed worklogs, and count them
      team_logs = Worklog.where(author: team.users)
      disputes = WorklogResponse.where(worklog: team_logs, status: WorklogResponse.reject_status)
      disputed_logs = Worklog.where(id: disputes.pluck(:worklog_id)).count

      # Add teams to list if there are disputes
      unless disputed_logs == 0
        @team_disputes[team.id] = disputed_logs
      end
    end
  end

  def account
    @title = "My Account"

    # Find all teams a student is part of
    unless current_user.staff
      @teams = current_user.teams
    end
  end

  def about
    @title = "About"
  end

end
