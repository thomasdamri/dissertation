
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
