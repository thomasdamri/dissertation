class EditForeignKeys < ActiveRecord::Migration[6.0]
  def change

    remove_foreign_key :assessment_results, :users, column: "author_id"
    remove_foreign_key :assessment_results, :users, column: "target_id"
    add_foreign_key :assessment_results, :student_teams, column: "author_id"
    add_foreign_key :assessment_results, :student_teams, column: "target_id"

  end
end
