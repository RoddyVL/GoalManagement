Rails.application.routes.draw do
  scope "(:locale)", locale: /fr|en/ do

    get 'landing_page/index'
    devise_for :users
    root to: "goals#index"
    # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

    # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
    # Can be used by load balancers and uptime monitors to verify that the app is live.
    get "up" => "rails/health#show", as: :rails_health_check

    # Defines the root path route ("/")
    # root "posts#index"

    get 'calendars', to: 'calendar#index'
    get 'landing', to: 'landing_page#index'

    resources :goals, only: %i[new create index show edit update destroy] do
      member do
        get :reassign
      end
      resources :calendars, only: %i[index]
      resources :steps, only: %i[new create edit update destroy]
      resources :sessions, only: %i[new create]
      resources :time_slots, only: %i[new create destroy index] do
        collection do
          get :generate_calendar
          get :redefine_slots
          delete :destroy_all
        end
      end
    end

    resources :steps, only: %i[edit update destroy show] do
      member do
        patch :toggle_status
        patch :move_up
        patch :move_down
        patch :move_up_new
        patch :move_down_new
      end
    end
  end
end
