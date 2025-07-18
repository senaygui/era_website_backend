Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root to: "admin/dashboard#index"

  namespace :api do
    namespace :v1 do
      # Add your API endpoints here
      # resources :admin_users, only: [ :index, :show, :update, :destroy ]
      resources :news, only: [ :index, :show ], param: :slug
      resources :events, only: [ :index, :show ] do
        collection do
          get :featured
          get :upcoming
        end
      end

      # Projects endpoints
      resources :projects, only: [ :index, :show ] do
        collection do
          get :completed
          get :ongoing
        end
      end

      # Bids endpoints
      resources :bids, only: [ :index, :show ] do
        collection do
          get :active
          get :closed
        end
      end

      # Vacancies endpoints
      resources :vacancies, only: [ :index, :show ] do
        collection do
          get :active
          get :expired
        end
      end

      # Districts endpoints
      resources :districts, only: [ :index, :show ] do
        collection do
          get :published
        end
      end

      # About Us endpoint
      get "about", to: "about#index"

      # Applicants endpoints
      resources :applicants
    end
  end
end
