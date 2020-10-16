class CreateReplacementStudentTeams < ActiveRecord::Migration[6.0]
  def change
    drop_table :student_teams
    create_table :student_teams do |t|
      t.belongs_to :user
      t.belongs_to :team
    end
  end
end
