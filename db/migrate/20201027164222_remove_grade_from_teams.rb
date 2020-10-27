class RemoveGradeFromTeams < ActiveRecord::Migration[6.0]
  def change
    remove_column :teams, :grade
  end
end
