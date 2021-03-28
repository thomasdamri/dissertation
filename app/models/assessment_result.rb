# == Schema Information
#
# Table name: assessment_results
#
#  id           :bigint           not null, primary key
#  author_id    :bigint
#  target_id    :bigint
#  criterium_id :bigint
#  value        :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class AssessmentResult < ApplicationRecord

  def self.max_value_length
    return 250
  end

  belongs_to :criterium
  has_one :assessment, through: :criterium
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  belongs_to :target, class_name: 'User', foreign_key: 'target_id', optional: true

  # Must have an associated criterium + an author. Target is optional (for non-team criteria)
  validates :criterium_id, presence: true
  validates :author_id, presence: true
  # Value must be 250 characters or less, and must exist
  validates :value, presence: true, length: { maximum:  self.max_value_length }

  validates_with AssessmentResultValidator

end
