# == Schema Information
#
# Table name: student_teams
#
#  id      :bigint           not null, primary key
#  user_id :bigint
#  team_id :bigint
#
class StudentTeam < ApplicationRecord

  belongs_to :user
  belongs_to :team

  has_many :student_weightings

  # A user can only be added to a team once
  validates :user, uniqueness: {scope: :team}

end
