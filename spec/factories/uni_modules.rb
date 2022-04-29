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

  factory :start_and_finish_monday_uni_module, class: 'UniModule' do
    name { 'Monday Module' }
    code { 'TST1002' }
    start_date { Date.today.prev_occurring(:monday) }
    end_date { Date.today.next_occurring(:monday) }
  end

  factory :no_monday_uni_module, class: 'UniModule' do
    name { 'No Monday Module' }
    code { 'TST1003' }
    start_date { Date.today.prev_occurring(:monday) -2 }
    end_date { Date.today.next_occurring(:monday)+2 }
  end

  factory :empty_uni_module, class: 'UniModule' do
    name {}
    code {}
  end

  factory :on_week_2_uni_module, class: 'UniModule' do
    name { 'Week 2 Module' }
    code { 'TST1004' }
    start_date { Date.today.prev_occurring(:monday) -12 }
    end_date { Date.today.next_occurring(:monday)+5 }
  end

  factory :week_0_uni_module, class: 'UniModule' do
    name { 'Week 2 Module' }
    code { 'TST1004' }
    start_date { Date.today.prev_occurring(:monday)}
    end_date { Date.today.next_occurring(:monday)+5 }
  end


end
