class StudentTaskEdit < ApplicationRecord
  belongs_to :student_task

  before_update :set_previous_target_date

  def set_previous_target_date
    target_date = self.student_task.task_target_date
    self.previous_target_date = target_date
  end
end
