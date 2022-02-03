class StudentTask < ApplicationRecord
  belongs_to :student_team
  has_many :student_task_edits, optional: true


end
