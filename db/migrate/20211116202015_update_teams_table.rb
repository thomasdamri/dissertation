class UpdateTeamsTable < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :teams, :uni_modules, column: :uni_module_id, on_delete: :cascade
    remove_column :teams, :created_at
    remove_column :teams, :updated_at
    rename_column :teams, :number, :team_number
    add_column :teams, :team_grade, :float
  end
end
