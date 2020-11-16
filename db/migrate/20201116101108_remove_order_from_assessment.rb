class RemoveOrderFromAssessment < ActiveRecord::Migration[6.0]
  def change
    remove_column :criteria, :order
  end
end
