class UpdateStudentWeightingsTable < ActiveRecord::Migration[6.0]
  def change
    add_column :student_weightings, :student_team_id, :bigint
    add_foreign_key :student_weightings, :student_teams, column: :student_team_id, on_delete: :cascade
    remove_column :student_weightings, :created_at
    remove_column :student_weightings, :updated_at
    remove_column :student_weightings, :user_id
    add_foreign_key :student_weightings, :assessments, column: :assessment_id
  end
end
