class StudentChat < ApplicationRecord
  belongs_to :student_team
  has_one :user, through: :student_team
end
