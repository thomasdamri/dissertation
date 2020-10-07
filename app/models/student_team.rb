class StudentTeam < ApplicationRecord

  belongs_to :user
  belongs_to :team

  # A user can only be added to a team once
  validates :user, uniqueness: {scope: :team}

end
