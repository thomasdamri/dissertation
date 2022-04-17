class ChangeToDate < ActiveRecord::Migration[6.0]
  def change
    change_column :student_tasks, :task_target_date, :date
  end
end
