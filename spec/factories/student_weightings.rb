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
#  manual_set            :boolean
#
FactoryBot.define do
  factory :student_weighting do
    weighting { 1 }
    results_at_last_check { 0 }
    manual_set { false }
  end

  factory :blank_student_weighting, class: StudentWeighting do

  end

end
