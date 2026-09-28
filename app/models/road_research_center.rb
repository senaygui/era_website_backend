require "uri"

class RoadResearchCenter < ApplicationRecord
  include SeoMetadataSync

  # Associations
  has_many :road_research_technologies, dependent: :destroy
  has_many :road_research_laboratory_services, dependent: :destroy
  has_many :road_research_gallery_images, dependent: :destroy
  has_one_attached :hero_image
  has_one_attached :organizational_structure_image

  # Validations
  validates :title, presence: true
  validates :about, presence: true
  validates :singleton_key, inclusion: { in: [ 1 ] }, if: :singleton_key_attribute?
  validates :singleton_key, uniqueness: true, if: :singleton_key_attribute?
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validate :validate_landing_page_images
  validate :contact_map_url_is_safe

  # Ensure singleton_key always set to 1
  before_validation :ensure_singleton_key, if: :singleton_key_attribute?
  syncs_seo_metadata title: :title,
                      description: [ :hero_subheadline, :about ],
                      keywords: [ :title, :hero_headline ]

  # Admin/Ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[about contact_address contact_email contact_hours contact_map_url contact_phone created_at hero_headline
       hero_subheadline is_published meta_description meta_keywords meta_title mission objectives
       organizational_structure title updated_at vision]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[hero_image_attachment hero_image_blob organizational_structure_image_attachment
       organizational_structure_image_blob road_research_gallery_images road_research_laboratory_services
       road_research_technologies]
  end

  # Convenience accessor to get-or-create the singleton record
  def self.instance
    first_or_create!(title: "Road Research Center", about: "Road Research Center content")
  end

  private

  def ensure_singleton_key
    self.singleton_key ||= 1
  end

  def singleton_key_attribute?
    has_attribute?(:singleton_key)
  end

  def validate_landing_page_images
    [ :hero_image, :organizational_structure_image ].each do |name|
      image = public_send(name)
      next unless image.attached?

      unless image.blob.content_type.in?(%w[image/jpeg image/png image/webp image/gif])
        errors.add(name, "must be JPEG, PNG, WebP, or GIF")
      end
      errors.add(name, "must be smaller than 10 MB") if image.blob.byte_size > 10.megabytes
    end
  end

  def contact_map_url_is_safe
    return if contact_map_url.blank?

    uri = URI.parse(contact_map_url)
    return if uri.is_a?(URI::HTTP) && uri.host.present?

    errors.add(:contact_map_url, "must be a valid HTTP or HTTPS URL")
  rescue URI::InvalidURIError
    errors.add(:contact_map_url, "must be a valid URL")
  end
end
