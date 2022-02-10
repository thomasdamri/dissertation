# == Schema Information
#
# Table name: student_weightings
#
#  id                    :bigint           not null, primary key
#  user_id               :bigint
#  assessment_id         :bigint
#  weighting             :float(24)
#  results_at_last_check :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  manual_set            :boolean          default(FALSE)
#  reason                :string(255)
#
class StudentWeighting < ApplicationRecord

  #belongs_to :user
  belongs_to :assessment

  belongs_to :student_teams

  has_many :assessment_results

  validates :weighting, presence: true
  validates :results_at_last_check, presence: true
  # A user can only have one weighting result per assessment
  validates :user, uniqueness: {scope: :assessment}
  validates :manual_set, inclusion: {in: [true, false]}

  # Checks that a reason is always provided when manually changed
  validates_with StudentWeightingValidator

  # Updates the weighting attribute and results at last check together
  def update_weighting(new_weighting, new_results)
    # If the weighting is manually set, do not update it
    unless manual_set
      self.weighting = new_weighting
      self.results_at_last_check = new_results
      save
    end
  end

  # Manually sets the weighting of the object
  def manual_update(new_weighting, new_reason)
    self.manual_set = true
    self.reason = new_reason
    self.weighting = new_weighting
    save
  end

end
