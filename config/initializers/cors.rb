# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors


Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    allowed_origins = if Rails.env.production?
      ENV.fetch("CORS_ALLOWED_ORIGINS", "https://prod-era.era.gov.et").split(",").map(&:strip)
    else
      %w[http://localhost:8080 http://127.0.0.1:8080]
    end

    origins(*allowed_origins)

    resource "/api/*",
      headers: :any,
      methods: [ :get, :post, :options, :head ],
      credentials: false,
      max_age: 600

    resource "/rails/active_storage/*",
      headers: :any,
      methods: [ :get, :head, :options ],
      credentials: false,
      max_age: 600
  end
end
