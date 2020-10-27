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
#
class StudentWeighting < ApplicationRecord

  belongs_to :user
  belongs_to :assessment

  validates :weighting, presence: true
  validates :results_at_last_check, presence: true
  # A user can only have one weighting result per assessment
  validates :user, uniqueness: {scope: :assessment}

  # Updates the weighting attribute and results at last check together
  def update_weighting(new_weighting, new_results)
    self.weighting = new_weighting
    self.results_at_last_check = new_results
    save
  end

end
