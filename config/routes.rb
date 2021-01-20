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
  get 'about', to: 'home#about', as: 'about'

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
  get 'teams/:id/:assess/view_ind_grades', to: 'teams#view_ind_grades', as: 'view_ind_grades'
  post 'teams/:id/:assess/update_ind_grades', to: 'teams#update_ind_grades', as: 'update_ind_grades'

  # Admin routes
  get 'admin/dashboard'
  get 'admin/staff'
  get 'admin/students'
  get 'admin/modules'
  get 'admin/teams'
  post 'admin/make_student'
  post 'admin/make_staff'
  get 'admin/add_new_student', to: 'admin#add_new_student', as: 'add_new_student'
  post 'admin/new_student_process', to: 'admin#new_student_process', as: 'new_student_process'
  get 'admin/add_new_staff', to: 'admin#add_new_staff', as: 'add_new_staff'
  post 'admin/new_staff_process', to: 'admin#new_staff_process', as: 'new_staff_process'

  # Assessment routes
  get 'assessment/:id', to: 'assessments#show', as: 'assessment'
  get 'assessment/new/:id', to: 'assessments#new', as: 'new_assessment'
  post 'assessment/:id', to: 'assessments#create', as: 'create_assessment'
  get 'assessment/:id/fill_in', to: 'assessments#fill_in', as: 'fillin_assessment'
  post 'assessment/:id/process', to: 'assessments#process_assess', as: 'process_assessment'
  delete 'assessment/:id', to: 'assessments#destroy', as: 'delete_assessment'
  get 'assessment/:id/results', to: 'assessments#results', as: 'assessment_results'
  get 'assessment/:id/export', to: 'assessments#csv_export', as: 'assessment_export'
  post 'assessment/:id/send_email', to: 'assessments#send_score_email', as: 'assessment_score_email'
  get 'assessment/:id/show_team_grades', to: 'assessments#show_team_grades', as: 'show_team_grades'
  get 'assessment/:id/:team_id/get_ind_responses', to: 'assessments#get_ind_responses', as: 'get_ind_responses'

  # Module routes
  resources :uni_modules
  get 'uni_modules/:id/show_all_students', to: 'uni_modules#show_all_students', as: 'show_all_students'

  resources :teams
end
