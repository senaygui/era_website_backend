module Admin
  class EditorUploadsController < ApplicationController
    before_action :authenticate_admin_user!

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
      blob = ActiveStorage::Blob.find_signed!(params.require(:signed_id))

      unless ALLOWED_CONTENT_TYPES.include?(blob.content_type)
        return render json: { error: "Unsupported file type" }, status: :unprocessable_entity
      end
      if blob.byte_size > MAX_FILE_SIZE
        return render json: { error: "File must be smaller than 20 MB" }, status: :unprocessable_entity
      end

      current_admin_user.editor_files.attach(blob)
      attachment = current_admin_user.editor_files.attachments.find_by!(blob_id: blob.id)

      render json: {
        url: rails_blob_url(attachment, disposition: "inline"),
        filename: blob.filename.to_s,
        content_type: blob.content_type
      }
    rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
      render json: { error: "Invalid upload" }, status: :unprocessable_entity
    end
  end
end
