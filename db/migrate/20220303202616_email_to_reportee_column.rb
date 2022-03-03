class EmailToReporteeColumn < ActiveRecord::Migration[6.0]
  def change
    remove_column :student_reports, :reportee_response
    create_table :report_objects do |t|
      t.bigint :student_report_id
      t.string :reportee_response
      t.string :emailed, null: false, default: false
    end
    add_foreign_key :report_objects, :student_reports, column: :student_report_id, on_delete: :cascade
  end
end
