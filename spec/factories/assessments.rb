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
#
FactoryBot.define do

  factory :assessment, class: Assessment do
    name { 'Test Assessment' }
    date_opened { Date.new(2020, 10, 30) }
    date_closed { Date.new(2020, 11, 10) }
  end

  factory :blank_assessment, class: Assessment do
    name { }
    date_opened {}
    date_closed {}
  end

end
