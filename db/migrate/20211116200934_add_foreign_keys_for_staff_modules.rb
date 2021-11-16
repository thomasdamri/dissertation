class AddForeignKeysForStaffModules < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :staff_modules, :users, column: :user_id, on_delete: :cascade
    add_foreign_key :staff_modules, :uni_modules, column: :uni_module_id, on_delete: :cascade
  end
end
