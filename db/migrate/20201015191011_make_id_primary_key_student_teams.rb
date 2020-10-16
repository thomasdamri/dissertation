class MakeIdPrimaryKeyStudentTeams < ActiveRecord::Migration[6.0]
  def change
    execute "ALTER TABLE student_teams ADD PRIMARY KEY (id);"
  end
end
