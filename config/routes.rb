Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # Fallback to allow POST update for RoadResearchCenter in admin when method override isn't applied
  post "/admin/road_research_centers/:id", to: "admin/road_research_centers#update"
  # Fallback to allow POST destroy for Bids in admin when method override isn't applied
  post "/admin/bids/:id", to: "admin/bids#destroy"
  # Fallback to allow POST destroy for Performance Reports in admin when method override isn't applied
  post "/admin/performance_reports/:id", to: "admin/performance_reports#destroy"
  # Fallback to allow POST destroy for other admin resources when method override isn't applied
  post "/admin/publications/:id", to: "admin/publications#destroy"
  post "/admin/road_assets/:id", to: "admin/road_assets#destroy"
  post "/admin/events/:id", to: "admin/events#destroy"
  post "/admin/news/:id", to: "admin/news#destroy"
  post "/admin/projects/:id", to: "admin/projects#destroy"
  post "/admin/vacancies/:id", to: "admin/vacancies#destroy"
  post "/admin/applicants/:id", to: "admin/applicants#destroy"
  post "/admin/districts/:id", to: "admin/districts#destroy"
  post "/admin/road_research_centers/:id/destroy", to: "admin/road_research_centers#destroy"
  post "/admin/about_us/:id", to: "admin/about_us#destroy"
  post "/admin/admin_users/:id", to: "admin/admin_users#destroy"
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

      # Publications endpoints
      resources :publications, only: [ :index, :show ] do
        member do
          get :download
        end
      end

      # Road Assets endpoints
      resources :road_assets, only: [ :index, :show ] do
        member do
          get :download
        end
      end

      # Road Research Centers endpoints
      resources :road_research_centers, only: [ :index, :show ] do
        member do
          get :download
        end
      end

      # Performance Reports endpoints
      resources :performance_reports, only: [ :index, :show ] do
        member do
          get :download
        end
      end

      # Performance Rates alias endpoints (same controller)
      resources :performance_rates, only: [ :index, :show ], controller: :performance_reports do
        member do
          get :download
        end
      end

      # Applicants endpoints
      resources :applicants
    end
  end
end
