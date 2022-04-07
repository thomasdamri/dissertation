class StudentChat < ApplicationRecord
  belongs_to :student_team
  has_one :user, through: :student_team
  
  after_create_commit {broadcast_prepend_to ("Team-"+self.student_team.team.id.to_s), target: "student_chats", locals: {user_id: self.get_user_id().to_i}}

  def get_user_id()
    return StudentTeam.find_by(id:self.student_team_id).user_id
  end

end
