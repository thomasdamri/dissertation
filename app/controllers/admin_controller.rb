class AdminController < ApplicationController
  before_action :authenticate_user!
  # Authorise with cancancan, without a db model
  authorize_resource class: false

  skip_before_action :verify_authenticity_token, only: [:new_student_process, :new_staff_process]

  def dashboard
    @title = "Admin Dashboard"
  end

  # List of all students
  def students
    authorize! :students, :admin
    @title = "Admin Students List"
    @users = User.where(staff: false).order(:username).paginate(page: params[:page])
  end

  # List of all staff
  def staff
    @title = "Admin Staff List"
    @users = User.where(staff: true).order(:username).paginate(page: params[:page])
  end

  # List of all modules
  def modules
    @title = "Admin Modules List"
    @uni_modules = UniModule.all.order(:code).paginate(page: params[:page])
  end

  # List of all teams
  def teams
    @title = "Admin Teams List"
    @teams = Team.order(:uni_module_id, :number).paginate(page: params[:page])
  end

  def worklogs
    @uni_module = UniModule.find(params['mod_id'])
    @worklogs = []
    logs = Worklog.where(uni_module: @uni_module)
    # Manually order worklogs by team, then by fill date
    @uni_module.teams.each do |team|
      team_logs = logs.where(author: team.users).order(:fill_date)
      @worklogs.concat team_logs
    end
  end

=begin
  # Path for making the current user a staff member
  def make_staff
    current_user.staff = true
    current_user.save
    redirect_to '/'
  end

  # Path for making the current user a student
  def make_student
    current_user.staff = false
    current_user.save
    redirect_to '/'
  end
=end

  # Path for adding a new student manually (not through a CEIS TSV file)
  def add_new_student
    @user = User.new
    @user_type = "Student"
    @btn_text = "Create"
    render 'add_user'
  end

  # Path for adding a new member of staff (can be admin, or not)
  def add_new_staff
    @user = User.new
    @user_type = "Staff"
    @btn_text = "Create"
    render 'add_user'
  end

  # Processes form for adding a new student
  def new_student_process
    @user = User.new(user_params)
    @user.staff = false
    @user.admin = false
    @btn_text = "Create"
    @user_type = "Student"

    if @user.save
      redirect_to admin_students_path, notice: "Successfully added student"
    else
      render :add_user
    end
  end

  # Processes form for adding a new staff member
  def new_staff_process
    @user = User.new(user_params)
    @user.staff = true
    # Admin will automatically be set by the form input

    @btn_text = "Create"
    @user_type = "Staff"

    if @user.save
      redirect_to admin_staff_path, notice: "Successfully added staff member"
    else
      render :add_user
    end
  end

  private
    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:username, :email, :admin, :display_name)
    end

end
