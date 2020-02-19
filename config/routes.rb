Rails.application.routes.draw do

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  devise_for :users
  get 'homepage/home'
  get "/", to: "homepage#home", as: "root"

  # Pages
  get "/about", to: "pages#about"
  get "/cooperation", to: "pages#cooperation"
  get "/contacts", to: "pages#contacts"
  get "/privacy-policy", to: "pages#privacy_policy"
  get "/privacy_policy_ios", to: "pages#privacy_policy_ios"
  get "/terms-of-service", to: "pages#terms_of_service"
  get "/zno-2019", to: "pages#zno2019"
  get "/ios", to: "pages#ios"
  get "/android", to: "pages#android"
  get "/telegram-channels", to: "pages#telegram_channels"

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

    # Buildings
    resources :buildings, only: [:index, :show], param: :id

    # Departments
    resources :departments, only: [:index, :show], param: :id

    # Faculties
    resources :faculties, only: [:index, :show], param: :id

    # Specialities
    resources :specialities, only: [:index, :show], param: :id
  end

  # API v1
  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :universities, only: [:index], param: :url do

        # Teachers API
        resources :teachers, only: [:index], param: :id do
          member do
            get :records
          end
        end

        # Auditoriums API
        resources :auditoriums, only: [:index], param: :id do
          member do
            get :records
          end
        end

        # Groups API
        resources :groups, only: [:index], param: :id do
          member do
            get :records
          end
        end

        # Buildings API
        resources :buildings, only: [:index], param: :id
      end

      # Records API
      resources :records, only: [] do
        collection do
          get :test
        end
      end
    end
  end

  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all
end
