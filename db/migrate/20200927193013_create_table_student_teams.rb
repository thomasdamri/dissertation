class CreateTableStudentTeams < ActiveRecord::Migration[6.0]
  def change
    create_table :student_teams, id: false do |t|
      t.belongs_to :user
      t.belongs_to :team
    end
  end
end
