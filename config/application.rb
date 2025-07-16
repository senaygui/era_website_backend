require_relative "boot"

require "rails/all"
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EraWebsiteBackend
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Add this line:
    config.session_store :cookie_store, key: "_era_website_backend_session"

    # This line is also important:
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use config.session_store, config.session_options
    config.middleware.delete ActionDispatch::Flash
    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])
    config.assets.enabled = true
    config.assets.paths << Rails.root.join("app", "assets", "fonts")
    config.assets.precompile += %w[ .svg .eot .woff .ttf ]
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # Configure Active Storage
    config.active_storage.service = :local
    config.active_storage.service_urls_expire_in = 1.hour
    config.active_storage.routes_prefix = "/rails/active_storage"

    # Configure logging
    config.log_level = :debug
    config.logger = ActiveSupport::Logger.new(STDOUT)
    config.logger.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime}: #{severity} -- #{msg}\n"
    end
  end
end
