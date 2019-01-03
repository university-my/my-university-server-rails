Rails.application.routes.draw do

  resources :universities, param: :url do
    resources :teachers, only: [:index, :show]
    resources :auditoriums, only: [:index, :show]
    resources :groups, only: [:index, :show]
  end
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
