class UpdateCriteriaTable < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :criteria, :assessments, column: :assessment_id, on_delete: :cascade
    remove_column :criteria, :created_at
    remove_column :criteria, :updated_at
  end
end
