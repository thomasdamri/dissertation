class CreateStudentWeightings < ActiveRecord::Migration[6.0]
  def change
    create_table :student_weightings do |t|
      t.belongs_to :user
      t.belongs_to :assessment
      t.float :weighting
      t.integer :results_at_last_check

      t.timestamps
    end
  end
end
