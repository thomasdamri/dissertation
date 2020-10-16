# == Schema Information
#
# Table name: assessments
#
#  id            :bigint           not null, primary key
#  name          :string(255)
#  uni_module_id :bigint
#  date_opened   :date
#  date_closed   :date
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Assessment < ApplicationRecord

  attr_accessor :mod

  has_many :criteria
  belongs_to :uni_module

  accepts_nested_attributes_for :criteria, reject_if: :all_blank, allow_destroy: true

  # Name of the assessment must not be the same as another assessment for the same module
  validates :name, uniqueness: {scope: :uni_module}, presence: true
  validates :date_opened, presence: true
  validates :date_closed, presence: true

  validates_with AssessmentValidator

  # Returns true if the given user has completed the assessment
  def completed_by?(user)
    # Check if the user has any authored results for this assessment's criteria
    if user.author_results.pluck(:criterium_id).include? criteria.first.id
      true
    else
      false
    end
  end

end
