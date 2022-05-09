FactoryBot.define do

  factory :student_report_type_0, class: StudentReport do
    report_reason {"Testing this report"}
    report_date {DateTime.now}
    object_type {0}
  end

  factory :student_report_type_1, class: StudentReport do
    report_reason {"Testing this report 2"}
    report_date {DateTime.now}
    object_type {1}
  end

  factory :student_report_type_2, class: StudentReport do
    report_reason {"Testing this report 3"}
    report_date {DateTime.now}
    object_type {2}
  end

  factory :empty_report, class: StudentReport do
    report_reason {""}
    report_date {DateTime.now}
    object_type {8}
  end

  factory :report_object, class: ReportObject do
    
  end

end
