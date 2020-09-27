class CreateAssessmentResults < ActiveRecord::Migration[6.0]
  def change
    create_table :assessment_results do |t|
      t.references :author, foreign_key: {to_table: 'users'}
      t.references :target, foreign_key: {to_table: 'users'}
      t.belongs_to :criterium
      t.string :value

      t.timestamps
    end
  end
end
