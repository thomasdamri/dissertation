class DeleteStaffModuleJoin < ActiveRecord::Migration[6.0]
  def change
    drop_join_table(:users, :uni_modules)
  end
end
