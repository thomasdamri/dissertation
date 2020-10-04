Rails.application.routes.draw do
  mount EpiCas::Engine, at: "/"
  devise_for :users
  root to: 'home#index'
  get 'home/index'
  get 'home/student_home'
  get 'home/staff_home'
  get 'home/account'

  get 'upload/users', to: 'upload#upload_users'
  post 'upload/process_users', to: 'upload#user_process'
  get 'upload/teams/:id', to: 'upload#upload_teams'
  post 'upload/process_teams/:id', to: 'upload#team_process'

  get 'admin/staff'
  get 'admin/students'
  get 'admin/modules'
  get 'admin/teams'

  resources :uni_modules
  resources :teams

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
