# == Schema Information
#
# Table name: uni_modules
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  code       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  start_date :date
#  end_date   :date
#
FactoryBot.define do
  factory :uni_module, class: 'UniModule' do
    name { 'Test Module' }
    code { 'TST1001' }
    start_date { Date.today.prev_occurring(:monday) - 7 }
    end_date { Date.today.next_occurring(:monday) + 49 }
  end

  factory :empty_uni_module, class: 'UniModule' do
    name {}
    code {}
  end

end
