class StudentChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team
  authorize_resource


  def post_chat
    authorize! :manage, @student_team
    @chat = StudentChat.new(chat_params)
    @chat.student_team_id = params[:student_team_id]
    @chat.posted = DateTime.now
    @chat.save 
  end

  def filter_chat
    authorize! :manage, @student_team
    selected = params[:student_team][:user_id].to_i
    filter = params[:student_team][:team_id].to_date
    @messages = @student_team.team.get_week_chats(selected, filter)
    current_range = filter..(filter + 7.day)
    if(current_range === Date.today)
      respond_to do |format|
        format.js { render "get_current_chat"}
      end
    else
      respond_to do |format|
        format.js 
      end
    end
  end

  private
    #Only allow a list of trusted parameters through.
    def chat_params
      params.require(:student_chat).permit(:chat_message)
    end

    def set_team
      @student_team = StudentTeam.find(params[:student_team_id])
    end

end