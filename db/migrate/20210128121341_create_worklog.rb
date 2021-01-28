class CreateWorklog < ActiveRecord::Migration[6.0]
  def change
    create_table :worklogs do |t|
      t.references :author, foreign_key: {to_table: 'users'}
      t.date :fill_date
      t.text :content
      t.text :override
      t.timestamps
    end
  end
end
