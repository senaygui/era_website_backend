class News < ApplicationRecord
  # Active Storage
  has_one_attached :image
  acts_as_taggable_on :tags

  # Validations
  validates :title, presence: true
  validates :content, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :category, presence: true
  validates :published_date, presence: true
  # validates :image, content_type: [ "image/png", "image/jpeg", "image/jpg", "image/gif" ],
  #                  size: { less_than: 5.megabytes }

  # Callbacks
  before_validation :generate_slug, on: :create
  before_validation :generate_excerpt, on: :create
  before_validation :set_meta_fields, on: :create

  # Scopes
  scope :published, -> { where(is_published: true) }
  scope :featured, -> { where(is_featured: true) }
  scope :recent, -> { order(published_date: :desc) }
  scope :by_category, ->(category) { where(category: category) }
  scope :search, ->(query) {
    where("title ILIKE :query OR content ILIKE :query OR excerpt ILIKE :query", query: "%#{query}%")
  }
  def self.ransackable_attributes(auth_object = nil)
    [ "author", "category", "content", "created_at", "excerpt", "id", "is_featured", "is_published", "meta_description", "meta_keywords", "meta_title", "published_date", "slug", "tags", "title", "updated_at", "view_count" ]
  end

  # Methods
  def increment_view_count
    increment!(:view_count)
  end

  def image_url
    Rails.application.routes.url_helpers.url_for(image) if image.attached?
  end

  private

  def generate_slug
    self.slug = title.parameterize if title.present?
  end

  def generate_excerpt
    return if excerpt.present?
    self.excerpt = content.truncate(200) if content.present?
  end

  def set_meta_fields
    self.meta_title ||= title
    self.meta_description ||= excerpt
    self.meta_keywords ||= tags if tags.present?
  end
end
