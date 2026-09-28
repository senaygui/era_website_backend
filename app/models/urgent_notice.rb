require "uri"

class UrgentNotice < ApplicationRecord
  ALLOWED_FILE_TYPES = %w[
    application/pdf
    application/msword
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
    application/vnd.ms-excel
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
    application/zip
    image/jpeg
    image/png
    image/webp
  ].freeze

  has_one_attached :file

  validates :notice_title, :notice_short_description, presence: true
  validate :has_one_destination
  validate :link_url_is_safe
  validate :file_is_supported

  scope :published, -> { where(is_published: true) }
  scope :not_expired, -> { where("expires_at IS NULL OR expires_at > ?", Time.current) }
  scope :newest_first, -> { order(created_at: :desc) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at expires_at id is_published link_url notice_short_description notice_title updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[file_attachment file_blob]
  end

  private

  def has_one_destination
    destination_count = [ file.attached?, link_url.present? ].count(true)
    errors.add(:base, "Attach a file or provide a link URL") if destination_count.zero?
    errors.add(:base, "Use either an attached file or a link URL, not both") if destination_count > 1
  end

  def link_url_is_safe
    return if link_url.blank?

    internal_path = link_url.start_with?("/") && !link_url.start_with?("//")
    return if internal_path

    uri = URI.parse(link_url)
    return if uri.is_a?(URI::HTTP) && uri.host.present?

    errors.add(:link_url, "must be an internal path or a valid HTTP/HTTPS URL")
  rescue URI::InvalidURIError
    errors.add(:link_url, "must be a valid URL")
  end

  def file_is_supported
    return unless file.attached?

    errors.add(:file, "type is not supported") unless file.blob.content_type.in?(ALLOWED_FILE_TYPES)
    errors.add(:file, "must be smaller than 20 MB") if file.blob.byte_size > 20.megabytes
  end
end
