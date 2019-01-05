Rails.application.routes.draw do

  get 'homepage/home'
  get "/", to: "homepage#home", as: "root"

  resources :universities, only: [:index, :show], param: :url do
    resources :teachers, only: [:index, :show]
    resources :auditoriums, only: [:index, :show]
    resources :groups, only: [:index, :show]
  end
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
