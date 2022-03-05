class EditsToReportingTables < ActiveRecord::Migration[6.0]
  def change
    remove_column :report_objects, :report_reason
    add_column :student_reports, :report_reason, :string, null: false
    rename_column :student_reports, :report_object, :object_type
    add_column :student_reports, :handled_by, :bigint, null: false
    rename_column :report_objects, :emailed, :action_taken
  end
end
