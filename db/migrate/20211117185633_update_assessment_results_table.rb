class UpdateAssessmentResultsTable < ActiveRecord::Migration[6.0]
  def change
    rename_column :assessment_results, :criterium_id, :criteria_id
    add_foreign_key :assessment_results, :criteria, column: :criteria_id, on_delete: :cascade
    add_column :assessment_results, :student_weightings_id, :bigint
    add_foreign_key :assessment_results, :student_weightings, column: :student_weightings_id, on_delete: :cascade
    remove_column :assessment_results, :created_at
    remove_column :assessment_results, :updated_at
  end
end
