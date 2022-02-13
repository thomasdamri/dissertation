class CreateTaskLikesTable < ActiveRecord::Migration[6.0]
  def change
    create_table :student_task_likes do |t|
      t.bigint :user_id
      t.bigint :student_task_id
    end
    add_foreign_key :student_task_likes, :student_tasks, column: :student_task_id, on_delete: :cascade
  end
end
