class WorklogsController < ApplicationController
  before_action :authenticate_user!
  skip_authorization_check

  # AJAX call to display the modal for filling in the worklog for the week
  def new_worklog
    @team = Team.find(params['team'])
    @uni_module = @team.uni_module

    # Check for an existing worklog from this week from this user
    if current_user.has_filled_in_log?(@uni_module)
      return redirect_to @team
    end

    respond_to do |format|
      format.js {render layout: false}
    end
  end

  # Processes the form for filling in a worklog
  def process_worklog
    @team = Team.find(params['team'])
    @uni_module = @team.uni_module

    # Check for an existing worklog from this week from this user
    if current_user.has_filled_in_log?(@uni_module)
      return redirect_to @team
    end

    # Create new worklog
    last_mon = Date.today.prev_occurring :monday
    Worklog.create(author: current_user, uni_module: @uni_module, fill_date: last_mon)

    redirect_to @team, notice: 'Work log uploaded succcessfully'

  end

  # Page for reviewing the past week's worklog
  def review_worklogs

  end

  # Page for showing all worklogs for a team
  def display_worklogs

  end

end
