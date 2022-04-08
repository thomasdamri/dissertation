class StudentTaskComment < ApplicationRecord
  belongs_to :student_task, counter_cache: true
  belongs_to :user
  has_one_attached :image
end
