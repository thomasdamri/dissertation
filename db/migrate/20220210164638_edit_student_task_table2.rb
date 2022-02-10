class EditStudentTaskTable2 < ActiveRecord::Migration[6.0]
  def change
    change_column_null :student_tasks, :task_objective, false
    change_column_null :student_tasks, :task_title, true
  end
end
