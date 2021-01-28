class AddWeekFieldsToModules < ActiveRecord::Migration[6.0]
  def change
    add_column :uni_modules, :start_date, :date
    add_column :uni_modules, :end_date, :date
  end
end
