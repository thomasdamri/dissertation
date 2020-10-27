# == Schema Information
#
# Table name: criteria
#
#  id            :bigint           not null, primary key
#  title         :string(255)
#  order         :integer
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

  factory :criterium, class: Criterium do
    title { 'Test Criterium' }
    order { 1 }
    response_type { 0 }
    single { true }
    assessed { false }
  end

  factory :weighted_criterium, class: Criterium do
    title { 'Test Criterium' }
    order { 1 }
    response_type { 1 }
    single { false }
    assessed { true }
    weighting { 1 }
    min_value { 1 }
    max_value { 10 }
  end

  factory :blank_criterium, class: Criterium do
    title {  }
    order {  }
    response_type {  }
    single {  }
    assessed {  }
  end

end
