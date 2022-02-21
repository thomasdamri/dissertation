class StudentReportsController < ApplicationController

  before_action :authenticate_user!
  authorize_resource


  # GET /uni_modules/new
  def new
    @title = "Creating Report"
    @student_report = StudentReport.new
  end

  def get_list
    @target = params[:target]
    @selected = params[:selected]
    if @selected == "User" 
      @item_list = ["1", "2", "3"]
    elsif @selected == "Grade" 
      @item_list = ["4", "5", "6"]
    elsif @selected == "Task" 
      @item_list = ["7", "8", "9"]
    else
      @item_list = ["10", "11", "12"]
    end
    puts(@item_list.inspect)
    respond_to do |format|
      format.turbo_stream
    end
  end

end