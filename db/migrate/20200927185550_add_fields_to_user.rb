class AddFieldsToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :display_name, :string
    add_column :users, :reg_no, :integer
    add_column :users, :staff, :boolean
    add_column :users, :admin, :boolean
  end
end
