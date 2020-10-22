class MakeResponseTypeInt < ActiveRecord::Migration[6.0]
  def change
    change_column :criteria, :response_type, :integer
  end
end
