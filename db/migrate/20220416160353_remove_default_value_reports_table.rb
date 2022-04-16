class RemoveDefaultValueReportsTable < ActiveRecord::Migration[6.0]
  def change
    change_column_default(:report_objects, :action_taken, from: 0, to: nil)
  end
end
