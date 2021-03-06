# == Schema Information
#
# Table name: teams
#
#  id            :bigint           not null, primary key
#  uni_module_id :bigint
#  number        :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Team < ApplicationRecord

  has_many :student_teams, dependent: :destroy
  has_many :users, through: :student_teams
  has_many :team_grades, dependent: :destroy
  has_many :student_reports, through: :student_teams
  has_many :student_tasks, through: :student_teams
  has_many :student_chats, through: :student_teams
  belongs_to :uni_module

  validates :team_number, presence: true, uniqueness: {scope: :uni_module}

  # Returns a string which can be used in email clients to email the entire team
  def group_email_link
    link = ""
    users.each do |u|
      link << u.email << ","
    end
    link.delete_suffix(',')
  end

  def get_week_chats(student_team_id, week_key)
    week_hash = self.uni_module.createWeekNumToDatesMap()
    if(student_team_id==-1)
      messages = self.student_chats.where(posted: week_key..(week_key+7.day)).order(posted: :desc)
      return messages
    else
      messages = self.student_chats.where(posted: week_key..(week_key+7.day), student_team_id: student_team_id).order(posted: :desc)
      return messages
    end
  end

end
