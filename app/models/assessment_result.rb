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

  belongs_to :criterium
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  belongs_to :target, class_name: 'User', foreign_key: 'target_id', optional: true

  validates :criterium_id, presence: true
  validates :author_id, presence: true
  validates :value, presence: true

end
