class ChangeCriteriaTableName < ActiveRecord::Migration[6.0]
  def change
    rename_table :criteria, :criterion
  end
end
