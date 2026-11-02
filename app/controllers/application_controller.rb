class ApplicationController < ActionController::Base
  around_action :use_requested_locale
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def not_found
    render json: { error: "Not Found" }, status: :not_found
  end

  def render_404
    render file: "public/404.html", status: :not_found, layout: false
  end

  rescue_from ActionController::RoutingError, with: :render_404
  rescue_from CanCan::AccessDenied, with: :access_denied

  def access_denied(exception)
    redirect_to admin_root_path, alert: exception.message
  end

  private

  def use_requested_locale(&action)
    requested = params[:lang].presence || params[:locale].presence || request.headers["Accept-Language"].to_s.split(",").first
    locale = request.path.start_with?("/api/") && requested.to_s.downcase.start_with?("am") ? :am : :en
    I18n.with_locale(locale, &action)
  end
end
