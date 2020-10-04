FactoryBot.define do
  factory :user, class: 'User' do
    username {'zzz12dp'}
    email {"dperry1@sheffield.ac.uk"}
    staff {true}
    admin {false}
  end

  factory :blank_user, class: 'User' do

  end

end