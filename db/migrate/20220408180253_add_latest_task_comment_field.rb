class AddLatestTaskCommentField < ActiveRecord::Migration[6.0]
  def change
    add_column :student_tasks, :latest_comment_time, :datetime
  end
end
