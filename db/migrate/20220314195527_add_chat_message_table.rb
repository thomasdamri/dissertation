class AddChatMessageTable < ActiveRecord::Migration[6.0]
  def change
    create_table :student_chats do |t|
      t.bigint :student_team_id
      t.text :chat_message, null: false
      t.datetime :posted, null: false
    end
    add_foreign_key :student_chats, :student_teams, column: :student_team_id, on_delete: :cascade
  end
end
