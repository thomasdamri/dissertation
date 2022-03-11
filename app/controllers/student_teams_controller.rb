class StudentTeamsController < ApplicationController
  before_action :authenticate_user!
  authorize_resource

  def index 
    @student_team = StudentTeam.find_by(id: params[:student_team_id])
    @task = StudentTask.new
    @student_report = StudentReport.new
    @student_report.report_objects.build
    @team_id = StudentTeam.find_by(id: params[:student_team_id]).team.id
    @item_list = []
    @users = StudentTeam.where(student_teams:{team_id: @team_id})
    for u in @users do
      @item_list.push([u.user.real_display_name, u.id])
    end
  end

  def team_data_index
    @test = StudentTeam.new
    @student_team = StudentTeam.find_by(id: params[:student_team_id])
    @select_options = [["Team", -1]]
    users = StudentTeam.where(student_teams:{team_id: @student_team.team_id})
    for u in users do
      @select_options.push([u.user.real_display_name, u.id])
    end
    @tables = []
    @tables.append(@student_team.teamTaskCountComparison())
    @tables.append(@student_team.getTaskCountPerStudent())

    respond_to do |format|
      format.js
    end
  end

  def team_data 
    @student_team = StudentTeam.find_by(id: params[:student_team_id])
    selected = params[:student_team][:user_id].to_i
    if(selected < 0)
      @student_team = StudentTeam.find_by(id: params[:student_team_id])
      @table2_data = @student_team.getTaskCountPerStudent()
      respond_to do |format|
        format.js 
      end
    else
      @student_team = StudentTeam.find_by(id: selected)
      @data1 = @student_team.uniqueStudentTaskCount()
      puts(@data1.inspect)
      respond_to do |format|
        format.js {render 'individual_data'}
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_team
      @student_team = Student_Team.find(params[:student_team_id])
    end

    # # Only allow a list of trusted parameters through.
    # def team_params
    #   params.fetch(:team, {})
    # end
end
