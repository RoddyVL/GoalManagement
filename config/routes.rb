Rails.application.routes.draw do
  devise_for :users
  root to: "goals#new"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  get 'calendars', to: 'calendar#index'

  resources :goals, only: %i[new create index] do
    resources :calendars, only: %i[index]
    resources :steps, only: %i[new create]
    resources :time_slots, only: %i[new create] do
      collection do
        get :generate_calendar
      end
    end
  end

  resources :steps, only: [] do
    member do
      patch :toggle_status
    end
  end

end
