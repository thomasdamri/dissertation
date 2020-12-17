Rails.application.routes.draw do
  mount EpiCas::Engine, at: "/"
  devise_for :users
  root to: 'home#index'
  get 'home/index'
  get 'home/student_home'
  get 'home/staff_home'
  get 'home/account'
  get 'about', to: 'home#about', as: 'about'

  get 'upload/users', to: 'upload#upload_users'
  post 'upload/process_users', to: 'upload#user_process'
  get 'upload/teams/:id', to: 'upload#upload_teams', as: 'upload_teams'
  post 'upload/process_teams/:id', to: 'upload#team_process', as: 'process_teams'
  delete 'upload/delete_teams/:id', to: 'upload#delete_teams', as: 'delete_teams'
  get 'upload/grades/:id', to: 'upload#upload_grades', as: 'upload_grades'
  post 'upload/process_grades/:id', to: 'upload#process_grades', as: 'process_grades'
  delete 'upload/delete_grades/:id', to: 'upload#delete_grades', as: 'delete_grades'

  get 'teams/grade_form/:id/:assess', to: 'teams#grade_form', as: 'teams_grade_form'
  post 'teams/set_grade', to: 'teams#set_grade', as: 'teams_set_grade'
  get 'teams/:id/:assess/view_ind_grades', to: 'teams#view_ind_grades', as: 'view_ind_grades'
  post 'teams/:id/:assess/update_ind_grades', to: 'teams#update_ind_grades', as: 'update_ind_grades'

  get 'admin/staff'
  get 'admin/students'
  get 'admin/modules'
  get 'admin/teams'
  post 'admin/make_student'
  post 'admin/make_staff'

  # I have to give the same url 2 names because Rails
  get 'assessment/:id', to: 'assessments#show', as: 'assessments'
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

  resources :uni_modules
  resources :teams

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
