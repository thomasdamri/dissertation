class StudentChatsController < ApplicationController
  before_action :authenticate_user!
  authorize_resource


  def post_chat
    @chat = StudentChat.new(chat_params)
    @chat.student_team_id = params[:student_team_id]
    @chat.posted = DateTime.now
    puts(@chat.inspect)
    if @chat.save 
    else
    end


  end

  #Only allow a list of trusted parameters through.
  def chat_params
    params.require(:student_chat).permit(:chat_message)
  end

end