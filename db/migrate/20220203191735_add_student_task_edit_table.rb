class AddStudentTaskEditTable < ActiveRecord::Migration[6.0]
  def change

    create_table :student_task_edits do |t|
      t.bigint :student_task_id
      
      t.string :edit_reason, null: false

      t.date :previous_target_date, null: false
    end
    add_foreign_key :student_task_edits, :student_tasks, column: :student_task_id, on_delete: :cascade

  end
end
