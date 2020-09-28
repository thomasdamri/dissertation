class CreateStaffUniModules < ActiveRecord::Migration[6.0]
  def change
    create_join_table :users, :uni_modules
  end
end
