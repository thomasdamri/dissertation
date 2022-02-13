class CreateTaskCommentsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :student_task_comments do |t|
      t.string :comment, null: false
      t.date  :posted_on
      t.bigint :user_id
      t.boolean :deleted, default: false, null: false
      t.bigint :student_task_id
    end
    add_foreign_key :student_task_comments, :student_tasks, column: :student_task_id, on_delete: :cascade
  end
end
