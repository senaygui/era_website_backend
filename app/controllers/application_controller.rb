class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def not_found
    render json: { error: 'Not Found' }, status: :not_found
  end

  def render_404
    render file: 'public/404.html', status: :not_found, layout: false
  end

  rescue_from ActionController::RoutingError, with: :render_404
end
