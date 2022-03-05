class StudentTeamsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

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
