class AddModuleIdToWorklog < ActiveRecord::Migration[6.0]
  def change
    add_column :worklogs, :uni_module_id, :bigint
  end
end
