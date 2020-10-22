class ChangeMinMaxValuesToString < ActiveRecord::Migration[6.0]
  def change
    change_column :criteria, :min_value, :string
    change_column :criteria, :max_value, :string
  end
end
