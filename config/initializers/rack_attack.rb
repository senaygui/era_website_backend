class Rack::Attack
  throttle("admin-login/ip", limit: 10, period: 1.minute) do |request|
    request.ip if request.post? && request.path == "/admin/login"
  end

  throttle("applicants/ip", limit: 5, period: 10.minutes) do |request|
    request.ip if request.post? && request.path == "/api/v1/applicants"
  end

  throttle("direct-uploads/ip", limit: 30, period: 10.minutes) do |request|
    request.ip if request.post? && request.path == "/rails/active_storage/direct_uploads"
  end

  throttle("search/ip", limit: 60, period: 1.minute) do |request|
    request.ip if request.get? && request.path == "/api/v1/search"
  end

  blocklist("oversized-applicant-request") do |request|
    request.post? && request.path == "/api/v1/applicants" && request.content_length.to_i > 30.megabytes
  end

  self.throttled_responder = lambda do |request|
    retry_after = request.env.dig("rack.attack.match_data", :period).to_i
    [429, { "Content-Type" => "application/json", "Retry-After" => retry_after.to_s }, [{ error: "Rate limit exceeded" }.to_json]]
  end

  self.blocklisted_responder = lambda do |_request|
    [413, { "Content-Type" => "application/json" }, [{ error: "Request body is too large" }.to_json]]
  end
end
