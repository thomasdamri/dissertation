class SwapAgain < ActiveRecord::Migration[6.0]
  def change
    rename_table :criterion, :questions
    rename_column :assessment_results, :criteria_id, :question_id
  end
end
