Rails.application.routes.draw do
  # Active Storage's default direct-upload endpoint is public. Route it through
  # an authenticated controller before Active Storage draws its fallback route.
  post "/rails/active_storage/direct_uploads", to: "admin/direct_uploads#create"

  # Admin POST fallbacks with method override constraints
  # Route POST + _method=delete to destroy; otherwise to update
  [
    :publications,
    :performance_reports,
    :road_assets,
    :events,
    :news,
    :projects,
    :vacancies,
    :applicants,
    :districts,
    :about_us,
    :bids,
    :admin_users,
    :road_research_centers,
    :road_research_technologies,
    :road_research_laboratory_services,
    :road_research_gallery_images,
    :urgent_notices,
    :featured_sections
  ].each do |res|
    post "/admin/#{res}/:id", to: "admin/#{res}#destroy", constraints: ->(req) { req.params['_method'].to_s.downcase == 'delete' }
    post "/admin/#{res}/:id", to: "admin/#{res}#update",  constraints: ->(req) { req.params['_method'].to_s.downcase != 'delete' }
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root to: "admin/dashboard#index"
  get "share/news/:slug", to: "news_shares#show", as: :share_news

  namespace :api do
    namespace :v1 do
      # Add your API endpoints here
      # resources :admin_users, only: [ :index, :show, :update, :destroy ]
      get "search", to: "search#index"
      get "youtube/latest", to: "youtube#latest"
      resources :featured_sections, only: :index
      resources :urgent_notices, only: :index
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
      resources :applicants, only: :create
      resources :contact_messages, only: :create
    end
  end

  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_scope :admin_user do
    # Compatibility for cached/legacy Active Admin assets that submit logout
    # as POST. The Devise scope supplies the required admin_user mapping.
    post "/admin/logout", to: "active_admin/devise/sessions#destroy"
  end
  namespace :admin do
    resources :editor_uploads, only: :create
  end
  ActiveAdmin.routes(self)
end
