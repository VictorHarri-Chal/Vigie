Rails.application.routes.draw do
  root "pavs#index"

  devise_for :users

  resources :pavs, only: [ :index, :show ]

  get "stats" => "stats#index", as: :stats

  resources :incidents, only: [ :index ] do
    member do
      patch :resolve
      patch :reopen
      patch :update_note
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
