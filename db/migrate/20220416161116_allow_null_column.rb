class AllowNullColumn < ActiveRecord::Migration[6.0]
  def change
    change_column :report_objects, :action_taken, :string, null: true
  end
end
