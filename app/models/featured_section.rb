require "uri"

class FeaturedSection < ApplicationRecord
  PAGE_OPTIONS = {
    "All pages" => "all",
    "Home" => "home",
    "About" => "about",
    "Contact" => "contact",
    "News listing" => "news",
    "News detail" => "news_detail",
    "FAQ" => "faq",
    "Vacancies" => "vacancies",
    "Events" => "events",
    "Bids" => "bids",
    "Publications" => "publications",
    "Road assets" => "road_assets",
    "Road Research Center" => "road_research_center",
    "Performance" => "performance",
    "Projects listing" => "projects",
    "Project detail" => "project_detail",
    "Districts listing" => "districts",
    "District detail" => "district_detail",
    "Search results" => "search",
    "404 / unmatched page" => "not_found"
  }.freeze

  has_one_attached :main_photo

  validates :title, :description, :cta_label, :cta_url, presence: true
  validates :display_order, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :section_position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :page_keys_are_supported
  validate :cta_url_is_supported
  validate :main_photo_is_present
  validate :main_photo_is_an_image

  scope :published, -> { where(is_published: true) }
  scope :ordered, -> { order(:section_position, :display_order, :created_at) }
  scope :for_page, ->(page_key) {
    where("'all' = ANY(page_keys) OR ? = ANY(page_keys)", page_key.to_s)
  }

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at cta_label cta_url description display_order id is_published page_keys section_position title updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[main_photo_attachment main_photo_blob]
  end

  private

  def page_keys_are_supported
    self.page_keys = Array(page_keys).reject(&:blank?).uniq
    errors.add(:page_keys, "must include at least one page") if page_keys.empty?

    unsupported = page_keys - PAGE_OPTIONS.values
    errors.add(:page_keys, "contains unsupported pages: #{unsupported.join(', ')}") if unsupported.any?
  end

  def cta_url_is_supported
    internal_path = cta_url.to_s.start_with?("/") && !cta_url.to_s.start_with?("//")
    return if cta_url.blank? || internal_path

    uri = URI.parse(cta_url)
    valid = if uri.is_a?(URI::HTTP)
      uri.host.present?
    elsif %w[mailto tel].include?(uri.scheme)
      uri.opaque.present?
    else
      false
    end
    return if valid

    errors.add(:cta_url, "must be an internal path or an HTTP, HTTPS, email, or telephone URL")
  rescue URI::InvalidURIError
    errors.add(:cta_url, "must be a valid URL")
  end

  def main_photo_is_present
    errors.add(:main_photo, "must be attached") unless main_photo.attached?
  end

  def main_photo_is_an_image
    return unless main_photo.attached?
    return if main_photo.blob.content_type.to_s.start_with?("image/")

    errors.add(:main_photo, "must be an image")
  end
end
