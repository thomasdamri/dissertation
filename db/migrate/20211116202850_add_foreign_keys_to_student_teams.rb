class AddForeignKeysToStudentTeams < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :student_teams, :users, column: :user_id, on_delete: :cascade
    add_foreign_key :student_teams, :teams, column: :team_id, on_delete: :cascade
  end
end
