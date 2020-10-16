class MakeIdAutoincrementStudentTeams < ActiveRecord::Migration[6.0]
  def change
    "Alter table student_teams modify column id int(11) auto_increment;"
  end
end
