class EditingHandledByField < ActiveRecord::Migration[6.0]
  def change
    change_column_null :student_reports, :handled_by, true
  end
end
