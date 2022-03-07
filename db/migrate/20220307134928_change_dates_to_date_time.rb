class ChangeDatesToDateTime < ActiveRecord::Migration[6.0]
  def change
    change_column :student_tasks, :task_start_date, :datetime
    change_column :student_tasks, :task_target_date, :datetime
    change_column :student_tasks, :task_complete_date, :datetime
    change_column :student_task_edits, :previous_target_date, :datetime
    change_column :student_task_comments, :posted_on, :datetime
    change_column :student_reports, :report_date, :datetime
  end
end
