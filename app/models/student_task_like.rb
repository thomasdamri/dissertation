class StudentTaskLike < ApplicationRecord
  belongs_to :student_task, counter_cache: true
  belongs_to :user


  
end
