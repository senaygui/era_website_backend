module Api
  class ApiController < ActionController::Base
    # Skip CSRF protection for API endpoints
    skip_before_action :verify_authenticity_token
    
    # Return JSON by default
    respond_to :json
  end
end
