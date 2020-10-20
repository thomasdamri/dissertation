class AddFieldsToCriteria < ActiveRecord::Migration[6.0]
  def change
    add_column :criteria, :assessed, :boolean
    add_column :criteria, :weighting, :integer
    add_column :criteria, :single, :boolean
  end
end
