FactoryBot.define do

  factory :comment, class: StudentTaskComment do
    comment {"HELLO"}
    posted_on {DateTime.now}
  end

  factory :empty_comment, class: StudentTaskComment do
    comment {""}
    posted_on {DateTime.now}
  end

end