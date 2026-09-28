require "securerandom"
require "uri"

class News < ApplicationRecord
  include FriendlySlug

  CATEGORIES = [
    "Road Construction & Development",
    "Project Progress Updates",
    "Road Maintenance",
    "Project Completion & Inauguration",
    "Road Safety",
    "Traffic & Road Conditions",
    "Bridges & Structures",
    "Regional Road Projects",
    "Engineering & Technology",
    "Environmental & Social",
    "Leadership & Management",
    "Events & Workshops",
    "Partnerships & Cooperation",
    "Community Engagement",
    "Studies & Research",
    "Policies & Standards",
    "Awards & Achievements",
    "Media & Press Releases",
    "Institutional Announcements",
    "Emergency Road Updates",
    "Infrastructure Development",
    "Training & Capacity Building",
    "International Cooperation",
    "Public Awareness",
    "Success Stories",
    "Featured News",
    "General News"
  ].freeze

  # Active Storage
  has_one_attached :image
  acts_as_taggable_on :tags

  # Validations
  validates :title, presence: true
  validates :content, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :published_date, presence: true
  validates :excerpt, length: { maximum: 256 }, allow_blank: true
  validate :youtube_url_must_be_supported
  # validates :image, content_type: [ "image/png", "image/jpeg", "image/jpg", "image/gif" ],
  #                  size: { less_than: 5.megabytes }

  # Callbacks
  has_friendly_slug source: :title, fallback: "news", history: :legacy_slugs
  before_validation :generate_excerpt, on: :create
  include SeoMetadataSync
  syncs_seo_metadata title: :title,
                      description: [ :excerpt, :content ],
                      keywords: [ :category, :tag_list ]

  # Scopes
  scope :published, -> { where(is_published: true) }
  scope :featured, -> { where(is_featured: true) }
  scope :recent, -> { order(published_date: :desc) }
  scope :by_category, ->(category) { where(category: category) }
  scope :search, ->(query) {
    where("title ILIKE :query OR content ILIKE :query OR excerpt ILIKE :query", query: "%#{query}%")
  }
  def self.ransackable_attributes(auth_object = nil)
    [ "author", "category", "content", "created_at", "excerpt", "id", "is_featured", "is_published", "meta_description", "meta_keywords", "meta_title", "published_date", "slug", "tags", "title", "updated_at", "view_count", "youtube_url" ]
  end

  # Methods
  def increment_view_count
    increment!(:view_count)
  end

  def image_url
    Rails.application.routes.url_helpers.url_for(image) if image.attached?
  end

  def youtube_video_id
    return if youtube_url.blank?

    uri = URI.parse(youtube_url.strip)
    host = uri.host.to_s.downcase.sub(/\Awww\./, "")
    video_id = if host == "youtu.be"
      uri.path.split("/").reject(&:blank?).first
    elsif host == "youtube.com" || host.end_with?(".youtube.com") ||
          host == "youtube-nocookie.com" || host.end_with?(".youtube-nocookie.com")
      path_match = uri.path.match(%r{\A/(?:embed|shorts|live)/([^/?]+)})
      path_match ? path_match[1] : URI.decode_www_form(uri.query.to_s).to_h["v"]
    end

    video_id if video_id&.match?(/\A[A-Za-z0-9_-]{11}\z/)
  rescue URI::InvalidURIError, ArgumentError
    nil
  end

  def youtube_embed_url
    video_id = youtube_video_id
    return if video_id.blank?

    "https://www.youtube-nocookie.com/embed/#{video_id}?playsinline=1&controls=1&rel=0"
  end

  private

  def generate_excerpt
    return if excerpt.present?

    self.excerpt = plain_text_content.truncate(256) if content.present?
  end

  def plain_text_content
    ActionView::Base.full_sanitizer.sanitize(content.to_s).squish
  end

  def youtube_url_must_be_supported
    return if youtube_url.blank? || youtube_video_id.present?

    errors.add(:youtube_url, "must be a valid YouTube watch, share, Shorts, live, or embed URL")
  end
end
