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
