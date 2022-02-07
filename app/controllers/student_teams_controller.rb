class StudentTeamsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index 
    @student_team = StudentTeam.find_by(params[:id])
    
  end

  


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_team
      @student_team = Student_Team.find(params[:id])
    end

    # # Only allow a list of trusted parameters through.
    # def team_params
    #   params.fetch(:team, {})
    # end
end
