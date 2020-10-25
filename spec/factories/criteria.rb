FactoryBot.define do

  factory :criterium, class: Criterium do
    title { 'Test Criterium' }
    order { 1 }
    response_type { 0 }
    single { true }
    assessed { false }
  end

  factory :blank_criterium, class: Criterium do
    title {  }
    order {  }
    response_type {  }
    single {  }
    assessed {  }
  end

end
