class RenameAssessmentType < ActiveRecord::Migration[6.0]
  def change

    rename_column :criteria, :type, :response_type

  end
end
