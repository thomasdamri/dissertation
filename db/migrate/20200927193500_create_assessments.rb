class CreateAssessments < ActiveRecord::Migration[6.0]
  def change
    create_table :assessments do |t|
      t.string :name
      t.belongs_to :uni_module
      t.date :date_opened
      t.date :date_closed

      t.timestamps
    end
  end
end
