class AddCounterCache < ActiveRecord::Migration[6.0]
  def change
    add_column :student_tasks, :student_task_likes_count, :bigint
    add_column :student_tasks, :student_task_comments_count, :bigint
  end
end
