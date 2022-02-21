class StudentReportsController < ApplicationController

  before_action :authenticate_user!
  authorize_resource


  # GET /uni_modules/new
  def new
    @title = "Creating Report"
    @student_report = StudentReport.new
  end

end