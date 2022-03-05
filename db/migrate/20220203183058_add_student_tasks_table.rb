class AddStudentTasksTable < ActiveRecord::Migration[6.0]
  def change
    create_table :student_tasks do |t|
      t.bigint :student_team_id
      

      t.string :task_title, null: false
      t.string :task_objective

      t.integer :task_difficulty, default: 0, null: false
      t.integer :task_progress, default: 0, null: false

      t.date :task_start_date
      t.date :task_target_date, null: false
      t.date :task_complete_date

    end
    add_foreign_key :student_tasks, :student_teams, column: :student_team_id, on_delete: :cascade
  end
end
