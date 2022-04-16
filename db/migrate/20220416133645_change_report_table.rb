class ChangeReportTable < ActiveRecord::Migration[6.0]
  def change
    add_column :report_objects, :emailed_reportee, :integer
    add_column :report_objects, :taken_action, :integer
  end
end
