# == Schema Information
#
# Table name: uni_modules
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  code       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :uni_module, class: 'UniModule' do
    name { 'Test Module' }
    code { 'TST1001' }
  end

  factory :empty_uni_module, class: 'UniModule' do
    name {}
    code {}
  end

end
