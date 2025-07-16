# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors


Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "http://localhost:8080", "http://localhost:3000", "http://127.0.0.1:8080", "http://localhost:8090",  "http://172.16.10.27:8080", "http://172.16.10.27:8000", "http://196.189.55.254", "http://196.189.55.254:8000", "http://196.189.55.254:8080", "http://196.189.55.254"# Allow specific frontend origins

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      credentials: false,
      expose: [ "Authorization" ]
  end
end
