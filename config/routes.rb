Rails.application.routes.draw do
  root "pavs#index"

  devise_for :users

  resources :pavs, only: [ :index, :show ]

  resources :incidents, only: [ :index ] do
    member do
      patch :resolve
      patch :reopen
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
