class WorklogsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

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
