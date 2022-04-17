class UpdateStringToTextField < ActiveRecord::Migration[6.0]
  def change
    change_column :student_tasks, :task_objective, :text, limit: 16.megabytes - 1
    remove_column :student_tasks, :task_title
    add_column :student_tasks, :hours, :integer

    change_column :student_task_comments, :comment, :text, limit: 16.megabytes - 1

    change_column :report_objects, :reportee_response, :text, limit: 16.megabytes - 1

    change_column :student_reports, :report_reason, :text, limit: 16.megabytes - 1
    change_column :student_reports, :reporter_response, :text, limit: 16.megabytes - 1

    change_column :student_task_edits, :edit_reason, :text, limit: 16.megabytes - 1

    add_column :student_tasks, :task_completed_summary, :text, limit: 16.megabytes - 1

    change_column :student_tasks, :task_target_date, :datetime
  end
end
