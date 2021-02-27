class AddReasonToStudentWeightng < ActiveRecord::Migration[6.0]
  def change
    add_column :student_weightings, :reason, :string
  end
end
