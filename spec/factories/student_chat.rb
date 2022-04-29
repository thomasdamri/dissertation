FactoryBot.define do

  factory :student_chat_one, class: StudentChat do
    chat_message {"HI"}
    posted {DateTime.now}
  end

  factory :student_chat_two, class: StudentChat do
    chat_message {"message 2"}
    posted {DateTime.now}
  end



end
