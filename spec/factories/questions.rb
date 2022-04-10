# == Schema Information
#
# Table name: criteria
#
#  id            :bigint           not null, primary key
#  title         :string(255)
#  response_type :integer
#  min_value     :string(255)
#  max_value     :string(255)
#  assessment_id :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  assessed      :boolean
#  weighting     :integer
#  single        :boolean
#
FactoryBot.define do

  factory :question, class: Question do
    title { 'Test question' }
    response_type { 0 }
    single { true }
    assessed { false }
  end

  factory :weighted_question, class: Question do
    title { 'Test question' }
    response_type { 1 }
    single { false }
    assessed { true }
    weighting { 1 }
    min_value { 1 }
    max_value { 10 }
  end

  factory :blank_question, class: Question do
    title {  }
    response_type {  }
    single {  }
    assessed {  }
  end

end
