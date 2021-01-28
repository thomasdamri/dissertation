class CreateWorklogResponse < ActiveRecord::Migration[6.0]
  def change
    create_table :worklog_responses do |t|
      t.belongs_to :worklog
      t.belongs_to :user
      t.integer :status
      t.text :reason
      t.timestamps
    end
  end
end
