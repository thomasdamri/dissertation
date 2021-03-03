# == Schema Information
#
# Table name: assessments
#
#  id            :bigint           not null, primary key
#  name          :string(255)
#  uni_module_id :bigint
#  date_opened   :date
#  date_closed   :date
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  show_results  :boolean
#
FactoryBot.define do

  factory :assessment, class: Assessment do
    name { 'Test Assessment' }
    date_opened { Date.today - 7 }
    date_closed { Date.today + 7 }
    show_results { false }
  end

  factory :blank_assessment, class: Assessment do
    name { }
    date_opened {}
    date_closed {}
  end

end
