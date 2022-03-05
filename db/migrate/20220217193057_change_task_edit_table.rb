class ChangeTaskEditTable < ActiveRecord::Migration[6.0]
  def change
    add_column :student_task_edits, :user_id, :integer, null: false
    add_column :student_task_edits, :edit_date, :datetime, null: false
  end
end
