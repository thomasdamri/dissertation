class StudentChat < ApplicationRecord
  belongs_to :student_team
  has_one :user, through: :student_team
  
  # After the chat is created, broadcast to the live room
  after_create_commit {broadcast_prepend_to ("Team-"+self.student_team.team.id.to_s), target: "student_chats", locals: {user_id: self.get_user_id().to_i}}

  # Validates chat isn't empty or too long
  validates :chat_message, length: {in: 1..300}

  # Returns the user id
  def get_user_id()
    return StudentTeam.find_by(id:self.student_team_id).user_id
  end

  # Explainer methods, used when user enquires for help
  def self.whatAreNotes()
    output = "The meeting notes tab is a live team chat.\n"
    output += "This chat is useful for teams communicating virtually, and may come in handy for teams who don't all share the same preferred communication apps.\n"
    output += "The chats are logged weekly, as to help in looking through previous weekly meetings."
    return output
  end

  def self.whatToNote()
    output = "The chat can be used for any project related chat.\n"
    output += "However, if students prefer another communication system, it is recommended to at least post weekly meeting notes to this chat."
    return output
  end

end
