class CreateTeamGrades < ActiveRecord::Migration[6.0]
  def change
    create_table :team_grades do |t|
      t.belongs_to :team
      t.belongs_to :assessment
      t.float :grade
      t.timestamps
    end
  end
end
