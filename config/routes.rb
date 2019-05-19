Rails.application.routes.draw do

  namespace :admin do
    resources :universities
  end
  devise_for :users
  get 'homepage/home'
  get "/", to: "homepage#home", as: "root"

  # Pages
  get "/about", to: "pages#about"
  get "/cooperation", to: "pages#cooperation"
  get "/contacts", to: "pages#contacts"
  get "/privacy-policy", to: "pages#privacy_policy"
  get "/terms-of-service", to: "pages#terms_of_service"
  get "/zno-2019", to: "pages#zno2019"
  get "/ios", to: "pages#ios"
  get "/android", to: "pages#android"

  resources :universities, only: [:index, :show], param: :url do
    
    # Teachers
    resources :teachers, only: [:index, :show], param: :id do
      member do
          get :records
        end
    end
    
    # Auditoriums
    resources :auditoriums, only: [:index, :show], param: :id do
      member do
          get :records
        end
    end
    
    # Groups
    resources :groups, only: [:index, :show], param: :id do
      member do
          get :records
        end
    end
  end
  
  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all
end
