class AddTeamGradeToTeams < ActiveRecord::Migration[6.0]
  def change
    add_column :teams, :grade, :float
  end
end
