class AddHiddenTaskField < ActiveRecord::Migration[6.0]
  def change
    add_column :student_tasks, :hidden, :boolean, default: false
  end
end
