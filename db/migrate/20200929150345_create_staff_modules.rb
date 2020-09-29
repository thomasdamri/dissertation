class CreateStaffModules < ActiveRecord::Migration[6.0]
  def change
    create_table :staff_modules do |t|
      t.belongs_to :user
      t.belongs_to :uni_module
    end
  end
end
