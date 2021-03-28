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
FactoryBot.define do

  factory :assessment_result_empty, class: AssessmentResult do

  end
  factory :assessment_result_string, class: AssessmentResult do
    value { "Test Result" }
  end
  factory :assessment_result_int, class: AssessmentResult do
    value { "3" }
  end
  factory :assessment_result_float, class: AssessmentResult do
    value { "3.14" }
  end
  factory :assessment_result_bool, class: AssessmentResult do
    value { "1" }
  end

end
