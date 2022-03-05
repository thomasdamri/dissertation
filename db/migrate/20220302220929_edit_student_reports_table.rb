class EditStudentReportsTable < ActiveRecord::Migration[6.0]
  def change
    add_column :student_reports, :reporter_response, :string
    add_column :student_reports, :reportee_response, :string
    add_column :student_reports, :complete, :boolean, default: false
  end
end
