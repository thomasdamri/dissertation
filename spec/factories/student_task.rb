FactoryBot.define do

  factory :empty_task, class: StudentTask do
    task_objective {""}
    task_difficulty {1}
    task_start_date {DateTime.now}
    task_target_date {Date.today + 6}
  end

  factory :student_task_one, class: StudentTask do
    task_objective {"task one"}
    task_difficulty {1}
    task_start_date {DateTime.now}
    task_target_date {Date.today + 6}
  end

  factory :student_task_two, class: StudentTask do
    task_objective {"task two"}
    task_difficulty {0}
    task_start_date {DateTime.now}
    task_target_date {Date.today + 3}
  end

  factory :student_task_complete, class: StudentTask do
    task_objective {"task completed"}
    task_difficulty {2}
    task_start_date {DateTime.now}
    task_target_date {Date.today + 3}
    task_complete_date {DateTime.now}
    hours {4}
    task_completed_summary {"Task was okay!"}
  end

  factory :student_task_late, class: StudentTask do
    task_objective {"task completed late"}
    task_difficulty {2}
    task_start_date {DateTime.now}
    task_target_date {Date.today + 3}
    task_complete_date {DateTime.now+6}
    hours {4}
    task_completed_summary {"Task was okay!"}
  end

  factory :student_task_easy, class: StudentTask do
    task_objective {"task easy"}
    task_difficulty {0}
    task_start_date {DateTime.now}
    task_target_date {Date.today + 3}
  end

  factory :student_task_medium, class: StudentTask do
    task_objective {"task medium"}
    task_difficulty {1}
    task_start_date {DateTime.now}
    task_target_date {Date.today + 3}
  end

  factory :student_task_hard, class: StudentTask do
    task_objective {"task hard"}
    task_difficulty {2}
    task_start_date {DateTime.now}
    task_target_date {Date.today + 3}
  end



end
