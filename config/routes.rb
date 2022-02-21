Rails.application.routes.draw do
  # This should stay at the top to ensure login paths work
  mount EpiCas::Engine, at: "/"
  devise_for :users

  # Home and dashboard routes
  root to: 'home#index'
  get 'home/index'
  get 'home/student_home'
  get 'home/staff_home'
  get 'home/account'
  get 'home/change_name/:id', to: 'home#change_name', as: 'change_name'
  post 'home/process_name_change/:id', to: 'home#process_name_change', as: 'process_name_change'
  get 'about', to: 'home#about', as: 'about'

  patch 'home/swap_staff_state', to: 'home#swap_staff_student_status', as: 'swap_state'

  # Routes for uploading CSV files
  get 'upload/users', to: 'uni_modules#upload_users', as: 'upload_users'
  post 'upload/process_users', to: 'uni_modules#user_process', as: 'process_users'
  get 'upload/teams/:id', to: 'uni_modules#upload_teams', as: 'upload_teams'
  post 'upload/process_teams/:id', to: 'uni_modules#team_process', as: 'process_teams'
  delete 'upload/delete_teams/:id', to: 'uni_modules#delete_teams', as: 'delete_teams'

  get 'upload/grades/:id', to: 'assessments#upload_grades', as: 'upload_grades'
  post 'upload/process_grades/:id', to: 'assessments#process_grades', as: 'process_grades'
  delete 'upload/delete_grades/:id', to: 'assessments#delete_grades', as: 'delete_grades'

  # Team routes (not associated with regular rails CRUD operations)
  get 'teams/grade_form/:id/:assess', to: 'teams#grade_form', as: 'teams_grade_form'
  post 'teams/set_grade', to: 'teams#set_grade', as: 'teams_set_grade'
  # Team routes associated with work logs, but the paths work better under teams because of cancancan
  get 'teams/new_worklog/:id', to: 'teams#new_worklog', as: 'new_worklog'
  post 'teams/process_worklog/:id', to: 'teams#process_worklog', as: 'process_worklog'
  get 'teams/review_worklogs/:id', to: 'teams#review_worklogs', as: 'review_worklogs'
  get 'teams/display_worklogs/:id', to: 'teams#display_worklogs', as: 'display_worklogs'
  get 'teams/display_log/:id/:weeks', to: 'teams#display_log', as: 'display_log'

  resources :teams

  # Admin routes
  get 'admin/dashboard'
  get 'admin/staff'
  get 'admin/students'
  get 'admin/modules'
  get 'admin/teams'
  get 'admin/worklogs/:mod_id', to: 'admin#worklogs', as: 'admin_worklogs'
  #post 'admin/make_student'
  #post 'admin/make_staff'
  get 'admin/add_new_student', to: 'admin#add_new_student', as: 'add_new_student'
  post 'admin/new_student_process', to: 'admin#new_student_process', as: 'new_student_process'
  get 'admin/add_new_staff', to: 'admin#add_new_staff', as: 'add_new_staff'
  post 'admin/new_staff_process', to: 'admin#new_staff_process', as: 'new_staff_process'

  # Assessment routes
  get 'assessment/:id', to: 'assessments#show', as: 'assessment'
  get 'assessment/new/:id', to: 'assessments#new', as: 'new_assessment'
  post 'assessment/:id', to: 'assessments#create', as: 'create_assessment'
  get 'assessment/edit/:id', to: 'assessments#edit', as: 'edit_assessment'
  patch 'assessment/edit/:id', to: 'assessments#update', as: 'update_assessment'
  get 'assessment/:id/fill_in', to: 'assessments#fill_in', as: 'fillin_assessment'
  get 'assessment/:id/mock_view', to: 'assessments#mock_view', as: 'mock_view_assessment'
  post 'assessment/:id/process', to: 'assessments#process_assess', as: 'process_assessment'
  delete 'assessment/:id', to: 'assessments#destroy', as: 'delete_assessment'
  get 'assessment/:id/results', to: 'assessments#results', as: 'assessment_results'
  get 'assessment/:id/export', to: 'assessments#csv_export', as: 'assessment_export'
  post 'assessment/:id/send_email', to: 'assessments#send_score_email', as: 'assessment_score_email'
  get 'assessment/:id/show_team_grades', to: 'assessments#show_team_grades', as: 'show_team_grades'
  get 'assessment/:id/:team_id/get_ind_responses', to: 'assessments#get_ind_responses', as: 'get_ind_responses'
  get 'assessment/:id/view_ind_grades', to: 'assessments#view_ind_grades', as: 'view_ind_grades'
  post 'assessment/:id/toggle_results', to: 'assessments#toggle_results', as: 'toggle_results'

  # StudentWeighting routes
  get 'student_weighting/:id/update_grade_form', to: 'student_weighting#update_grade_form', as: 'update_grade_form'
  post 'student_weighting/:id/process_grade_update', to: 'student_weighting#process_grade_update', as: 'process_grade_update'
  post 'student_weighting/:id/reset_grade', to: 'student_weighting#reset_grade', as: 'reset_grade'

  # Module routes
  resources :uni_modules
  get 'uni_modules/:id/show_all_staff', to: 'uni_modules#show_all_staff', as: 'show_all_staff'
  get 'uni_modules/:id/show_all_students', to: 'uni_modules#show_all_students', as: 'show_all_students'
  get 'uni_modules/view_disputes/:id', to: 'uni_modules#view_disputes', as: 'view_disputes'

  # Worklog routes
  get 'worklogs/dispute_form/:id', to: 'worklogs#dispute_form', as: 'dispute_form'
  post 'worklogs/dispute_worklog/:id', to: 'worklogs#dispute_worklog', as: 'dispute_worklog'
  post 'worklogs/accept_worklog/:id', to: 'worklogs#accept_worklog', as: 'accept_worklog'
  get 'worklogs/override_form/:id', to: 'worklogs#override_form', as: 'override_form'
  post 'worklogs/process_override/:id', to: 'worklogs#process_override', as: 'process_override'
  post 'worklogs/process_uphold/:id', to: 'worklogs#process_uphold', as: 'process_uphold'


  get 'student_teams/:student_team_id', to: 'student_teams#index', as: 'student_team_dashboard'
  post 'student_teams/:student_team_id/student_tasks_new',  to: 'student_tasks#create', as: 'student_task_create'

  get 'student_teams/:student_team_id/new_report', to: 'student_reports#new', as: 'new_report'

  get 'fetch_student_task', to: 'student_tasks#select'

  delete 'delete_comment/:id', to: 'student_tasks#delete_comment', as: 'delete_comment'

  resources :student_reports

  resources :student_tasks do
    post 'comment', to: 'student_tasks#comment'
    post 'like_task', to: 'student_tasks#like_task'
  end



end
