module Admin
  class DirectUploadsController < ApplicationController
    include ActiveStorage::SetCurrent

    before_action :authenticate_admin_user!
    before_action :validate_blob_metadata!

    ALLOWED_CONTENT_TYPES = %w[
      image/jpeg image/png image/gif image/webp
      application/pdf application/msword
      application/vnd.openxmlformats-officedocument.wordprocessingml.document
      application/vnd.ms-excel
      application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
      application/vnd.ms-powerpoint
      application/vnd.openxmlformats-officedocument.presentationml.presentation
      text/plain application/zip
    ].freeze
    MAX_FILE_SIZE = 20.megabytes

    def create
      blob = ActiveStorage::Blob.create_before_direct_upload!(**blob_args)
      render json: direct_upload_json(blob)
    end

    private

    def blob_args
      params.expect(blob: [ :filename, :byte_size, :checksum, :content_type, metadata: {} ]).to_h.symbolize_keys
    end

    def direct_upload_json(blob)
      blob.as_json(root: false, methods: :signed_id).merge(
        direct_upload: {
          url: blob.service_url_for_direct_upload,
          headers: blob.service_headers_for_direct_upload
        }
      )
    end

    def validate_blob_metadata!
      blob = params.require(:blob)
      content_type = blob[:content_type].to_s
      byte_size = Integer(blob[:byte_size], exception: false)

      return if ALLOWED_CONTENT_TYPES.include?(content_type) && byte_size&.between?(1, MAX_FILE_SIZE)

      render json: { error: "Unsupported file type or size" }, status: :unprocessable_entity
    end
  end
end
