class CreateTeams < ActiveRecord::Migration[6.0]
  def change
    create_table :teams do |t|
      t.belongs_to :uni_module
      t.integer :number

      t.timestamps
    end
  end
end
