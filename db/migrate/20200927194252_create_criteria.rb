class CreateCriteria < ActiveRecord::Migration[6.0]
  def change
    create_table :criteria do |t|
      t.string :title
      t.integer :order
      t.string :type
      t.float :min_value
      t.float :max_value
      t.belongs_to :assessment

      t.timestamps
    end
  end
end
