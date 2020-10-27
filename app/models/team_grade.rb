class TeamGrade < ApplicationRecord

  belongs_to :team
  belongs_to :assessment

  validates :grade, presence: true

end
