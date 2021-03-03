class AddShowResultsToAssessment < ActiveRecord::Migration[6.0]
  def change
    add_column :assessments, :show_results, :boolean
  end
end
