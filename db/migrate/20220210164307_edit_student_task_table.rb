class EditStudentTaskTable < ActiveRecord::Migration[6.0]
  def change
    change_column_null :student_tasks, :task_objective, true
    change_column_null :student_tasks, :task_title, false
  end
end
