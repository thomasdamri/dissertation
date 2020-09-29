Rails.application.routes.draw do
  mount EpiCas::Engine, at: "/"
  devise_for :users
  root to: 'home#index'
  get 'home/index'
  get 'home/student_home'
  get 'home/staff_home'

  resources :uni_modules

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
