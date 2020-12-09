class AddDefaultValueToManualSet < ActiveRecord::Migration[6.0]
  def change
    remove_column :student_weightings, :manual_set
    add_column :student_weightings, :manual_set, :boolean, default: false
  end
end
