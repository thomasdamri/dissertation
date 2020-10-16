class AddPrimaryKeyToStudentTeams < ActiveRecord::Migration[6.0]
  def change
    add_column :student_teams, :id, :bigint
  end
end
