class AddForeignKeysForAssessments < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :assessments, :uni_modules, column: :uni_module_id, on_delete: :cascade
  end
end
