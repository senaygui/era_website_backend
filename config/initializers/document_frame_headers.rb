require Rails.root.join("lib/document_frame_headers")

default_origins = if Rails.env.production?
  "https://prod-era.era.gov.et"
else
  "http://localhost:8080,http://127.0.0.1:8080"
end

Rails.application.config.middleware.insert_before 0, DocumentFrameHeaders,
  allowed_origins: ENV.fetch("DOCUMENT_FRAME_ALLOWED_ORIGINS", default_origins).split(",").map(&:strip).reject(&:empty?)
