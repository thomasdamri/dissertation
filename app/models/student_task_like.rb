class StudentTaskLike < ApplicationRecord
  belongs_to :student_task
  belongs_to :user
end
