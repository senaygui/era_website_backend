require "minitest/autorun"
require "rack/cors"
require "rack/mock"
require "ostruct"

class CorsConfigurationTest < Minitest::Test
  def middleware(production: true, origins: nil)
    previous = ENV["CORS_ALLOWED_ORIGINS"]
    origins.nil? ? ENV.delete("CORS_ALLOWED_ORIGINS") : ENV["CORS_ALLOWED_ORIGINS"] = origins
    stack = Object.new
    stack.define_singleton_method(:insert_before) do |_, klass, &block|
      @app = klass.new(->(_) { [ 200, { "content-type" => "application/json" }, [ "[]" ] ] }, &block)
    end
    stack.define_singleton_method(:app) { @app }
    rails = Module.new
    rails.define_singleton_method(:env) { OpenStruct.new(production?: production) }
    rails.define_singleton_method(:application) { OpenStruct.new(config: OpenStruct.new(middleware: stack)) }
    Object.const_set(:Rails, rails)
    load File.expand_path("../config/initializers/cors.rb", __dir__)
    stack.app
  ensure
    previous.nil? ? ENV.delete("CORS_ALLOWED_ORIGINS") : ENV["CORS_ALLOWED_ORIGINS"] = previous
    Object.send(:remove_const, :Rails) if rails && Object.const_defined?(:Rails)
  end

  def test_live_frontend_origins_can_read_every_failing_endpoint
    app = middleware
    %w[https://www.era.gov.et https://era.gov.et https://prod-era.era.gov.et].each do |origin|
      %w[/api/v1/news /api/v1/urgent_notices /api/v1/featured_sections?page=home /api/v1/events/upcoming /api/v1/events/featured /rails/active_storage/blobs/redirect/signed/photo.jpg].each do |path|
        response = Rack::MockRequest.new(app).get(path, "HTTP_ORIGIN" => origin)
        assert_equal origin, response["access-control-allow-origin"]
      end
    end
  end

  def test_json_preflight_is_allowed
    response = Rack::MockRequest.new(middleware).options("/api/v1/news",
      "HTTP_ORIGIN" => "https://www.era.gov.et",
      "HTTP_ACCESS_CONTROL_REQUEST_METHOD" => "GET",
      "HTTP_ACCESS_CONTROL_REQUEST_HEADERS" => "content-type")
    assert_equal 200, response.status
    assert_equal "https://www.era.gov.et", response["access-control-allow-origin"]
    assert_includes response["access-control-allow-headers"], "content-type"
  end

  def test_untrusted_origins_and_admin_routes_are_not_allowed
    app = Rack::MockRequest.new(middleware)
    assert_nil app.get("/api/v1/news", "HTTP_ORIGIN" => "https://untrusted.example")["access-control-allow-origin"]
    assert_nil app.get("/admin", "HTTP_ORIGIN" => "https://www.era.gov.et")["access-control-allow-origin"]
  end

  def test_environment_override_is_respected
    app = Rack::MockRequest.new(middleware(origins: " https://custom.example, ,https://other.example "))
    assert_equal "https://custom.example", app.get("/api/v1/news", "HTTP_ORIGIN" => "https://custom.example")["access-control-allow-origin"]
    assert_nil app.get("/api/v1/news", "HTTP_ORIGIN" => "https://www.era.gov.et")["access-control-allow-origin"]
  end

  def test_development_origins
    app = Rack::MockRequest.new(middleware(production: false))
    %w[http://localhost:8080 http://127.0.0.1:8080].each do |origin|
      assert_equal origin, app.get("/api/v1/news", "HTTP_ORIGIN" => origin)["access-control-allow-origin"]
    end
  end
end
