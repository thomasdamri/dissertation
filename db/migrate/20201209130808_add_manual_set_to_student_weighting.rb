class AddManualSetToStudentWeighting < ActiveRecord::Migration[6.0]
  def change
    add_column :student_weightings, :manual_set, :boolean
  end
end
