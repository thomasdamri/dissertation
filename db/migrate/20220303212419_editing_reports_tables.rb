class EditingReportsTables < ActiveRecord::Migration[6.0]
  def change
    remove_column :student_reports, :report_object_id
    remove_column :student_reports, :report_reason
    add_column :report_objects, :report_object_id, :bigint, null: false
    add_column :report_objects, :report_reason, :string, null: false
  end
end
