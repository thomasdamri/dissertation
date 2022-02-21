class CreateReportsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :student_reports do |t|
      t.bigint :student_team_id
      t.integer :report_object, null: false, comment: '0 if user, 1 if grade, 2 if task, 3 if team'
      t.bigint :report_object_id, null: false, comment: 'depending on report object type, object id will link to correct object'
      t.string :report_reason, null: false
      t.date :report_date, null: false
    end
    add_foreign_key :student_reports, :student_teams, column: :student_team_id, on_delete: :cascade
  end
end
