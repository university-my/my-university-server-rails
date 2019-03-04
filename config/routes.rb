Rails.application.routes.draw do

  get 'homepage/home'
  get "/", to: "homepage#home", as: "root"

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
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
