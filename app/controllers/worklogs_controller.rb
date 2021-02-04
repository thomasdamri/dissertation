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

  # Page to display all disputes for a module
  def view_disputes
    @uni_module = UniModule.find(params['uni_module'])
    @logs = {}
    @disputes = {}

    # Find the disputes for each worklog for each team
    @uni_module.teams.each do |team|
      logs = Worklog.where(author: team.users, uni_module: @uni_module).order(:fill_date)
      unless logs.count == 0
        disputes = WorklogResponse.where(worklog: logs, status: WorklogResponse.reject_status)
        unless disputes.count == 0
          @logs[team.id] = logs
          logs.each do |log|
            log_disputes = disputes.where(worklog: log)
            unless log_disputes.count == 0
              @disputes[log.id] = log_disputes
            end
          end
        end
      end
    end
  end

  # AJAX request to display modal form for override text
  def override_form
    @worklog = Worklog.find(params['id'])

    respond_to do |format|
      format.js { render layout: false }
    end
  end

  # Processes the override and resolves the disputes
  def process_override
    @worklog = Worklog.find(params['id'])
    @uni_module = @worklog.uni_module

    # Add the override response from the form to the work log object, and resolve all responses
    # Do this in a transaction to prevent an error halfway through resolving only some responses
    ActiveRecord::Base.transaction do
      @worklog.override = params['override']
      @worklog.save

      @worklog.worklog_responses.each do |resp|
        resp.status = WorklogResponse.resolved_status
        resp.save
      end
    end

    redirect_to view_disputes_path(@uni_module), notice: "Work log override successfully"
  end

  # Processes the upholding of a work log and resolves the disputes
  def process_uphold
    @worklog = Worklog.find(params['id'])
    @uni_module = @worklog.uni_module

    # Add the override response from the form to the work log object, and resolve all responses
    # Do this in a transaction to prevent an error halfway through resolving only some responses
    ActiveRecord::Base.transaction do
      @worklog.worklog_responses.each do |resp|
        resp.status = WorklogResponse.resolved_status
        resp.save
      end
    end

    redirect_to view_disputes_path(@uni_module), notice: "Work log upheld successfully"
  end

end
