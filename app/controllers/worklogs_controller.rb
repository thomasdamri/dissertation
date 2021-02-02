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

    # Check user actually entered content into the worklog
    if params["content"].nil?
      return redirect_to @team, notice: "Work log content cannot be blank"
    end

    # Create new worklog and ensure fill date is a monday
    wl = Worklog.create(author: current_user, uni_module: @uni_module, fill_date: Date.today, content: params['content'])
    wl.ensure_mondays

    redirect_to @team, notice: 'Work log uploaded successfully'

  end

  # Page for reviewing the past week's worklog
  def review_worklogs
    @title = "Review work logs"
    @team = Team.find(params['team'])
    @date = Date.today.monday? ? Date.today : Date.today.prev_occurring(:monday)
    @logs = Worklog.where(author: @team.users, uni_module: @team.uni_module, fill_date: @date)
  end

  # AJAX call to render a modal for the user to enter the reason for the work log dispute
  def dispute_form
    @worklog = Worklog.find(params['id'])

    respond_to do |format|
      format.js { render layout: false }
    end
  end

  # POST request processes a work log dispute and creates a response with a reason
  def dispute_worklog
    wl = Worklog.find(params['id'])
    @team = wl.author.teams.where(uni_module: wl.uni_module).first

    WorklogResponse.create(worklog: wl, user: current_user, status: WorklogResponse.reject_status, reason: params['reason'])

    redirect_to review_worklogs_path(@team)
  end

  # POST request processes a work log that has been accepts and creates a response
  def accept_worklog
    wl = Worklog.find(params['id'])
    @team = wl.author.teams.where(uni_module: wl.uni_module).first

    WorklogResponse.create(worklog: wl, user: current_user, status: WorklogResponse.accept_status)

    redirect_to review_worklogs_path(@team)
  end

  # Page for showing all worklogs for a team
  def display_worklogs
    @title = "Show all work logs"
    @team = Team.find(params['team'])
  end

  # AJAX call for showing a modal of one weeks worth of logs
  def display_log
    @team = Team.find(params['team'])
    @date = @team.uni_module.start_date + (7 * params["weeks"].to_i)

    # Stop date going past module end date
    if @date > @team.uni_module.end_date
      return redirect_to display_worklogs_path(@team), notice: "Error: Invalid date"
    end

    # Find all logs written in the given week by this team
    @logs = Worklog.where(author: @team.users, fill_date: @date, uni_module: @team.uni_module)
    puts "------"
    puts @logs.where(author: @team.users.first)

    respond_to do |format|
      format.js { render layout: false }
    end
  end

end
