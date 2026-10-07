require "uri"

# Runs outside Rails' header middleware so the policy reaches the final file
# response, including Active Storage's disk service and PDF range requests.
class DocumentFrameHeaders
  def initialize(app, allowed_origins:)
    @app = app
    @ancestors = [ "'self'", *allowed_origins.map { |origin| validate_origin(origin) } ].uniq.join(" ")
  end

  def call(env)
    status, headers, body = @app.call(env)
    if %w[GET HEAD].include?(env["REQUEST_METHOD"]) &&
        env["PATH_INFO"].to_s.start_with?("/rails/active_storage/") &&
        [ 200, 206 ].include?(status) &&
        headers["content-type"].to_s.split(";").first == "application/pdf"
      headers = headers.dup
      headers.delete("x-frame-options")
      directives = headers["content-security-policy"].to_s.split(";").map(&:strip)
      directives.reject! { |directive| directive.empty? || directive.split.first == "frame-ancestors" }
      headers["content-security-policy"] = [ *directives, "frame-ancestors #{@ancestors}" ].join("; ")
    end
    [ status, headers, body ]
  end

  private

  def validate_origin(origin)
    uri = URI.parse(origin)
    unless %w[http https].include?(uri.scheme) && uri.host &&
        !uri.userinfo && uri.path.to_s.empty? && !uri.query && !uri.fragment &&
        !origin.match?(/[\s;*]/)
      raise ArgumentError, "DOCUMENT_FRAME_ALLOWED_ORIGINS must contain exact HTTP(S) origins without paths"
    end
    origin
  end
end
