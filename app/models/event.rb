class Event < ApplicationRecord
  # ActiveStorage
  has_one_attached :event_image

  # RRC flag is stored as a boolean on events (no FK association)

  # Validations
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :location, presence: true
  validates :event_type, presence: true
  validate :end_date_after_start_date
  validate :image_content_type

  def self.ransackable_attributes(auth_object = nil)
    [ "agenda", "capacity", "created_at", "description", "end_date", "event_type", "excerpt", "id", "is_featured", "is_published", "is_road_research_center_event", "location", "meta_description", "meta_keywords", "meta_title", "registration_required", "slug", "speakers", "start_date", "status", "time", "title", "updated_at" ]
  end

  # Callbacks
  before_validation :generate_slug, on: :create
  before_validation :set_default_status, on: :create

  # Scopes
  scope :published, -> { where(is_published: true) }
  scope :featured, -> { where(is_featured: true) }
  scope :upcoming, -> { where("start_date > ?", Time.current).order(start_date: :asc) }
  scope :ongoing, -> { where("start_date <= ? AND end_date >= ?", Time.current, Time.current) }
  scope :past, -> { where("end_date < ?", Time.current).order(start_date: :desc) }
  scope :by_type, ->(type) { where(event_type: type) }
  scope :search, ->(query) {
    where("title ILIKE :query OR description ILIKE :query OR excerpt ILIKE :query",
          query: "%#{query}%")
  }

  # Methods
  def status
    return "cancelled" if super == "cancelled"
    return "ongoing" if start_date.present? && end_date.present? &&
                       start_date <= Time.current && end_date >= Time.current
    return "upcoming" if start_date.present? && start_date > Time.current
    "completed"
  end

  def duration
    return nil unless start_date && end_date
    ((end_date - start_date) / 1.hour).round
  end

  def formatted_start_date
    start_date&.strftime("%B %d, %Y")
  end

  def formatted_end_date
    end_date&.strftime("%B %d, %Y")
  end

  def formatted_time
    time || start_date&.strftime("%I:%M %p")
  end

  def available_capacity
    return nil unless capacity
    capacity - registrations.count
  end

  def registration_open?
    registration_required && start_date.present? && start_date > Time.current && available_capacity.to_i > 0
  end

  def image_url
    Rails.application.routes.url_helpers.url_for(event_image) if event_image.attached?
  end

  private

  def generate_slug
    return if slug.present?
    self.slug = title.parameterize
  end

  def set_default_status
    self.status ||= "upcoming"
  end

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?
    if end_date < start_date
      errors.add(:end_date, "must be after the start date")
    end
  end

  def image_content_type
    return unless event_image.attached?
    unless event_image.content_type.in?(%w[image/jpeg image/png image/gif])
      errors.add(:event_image, "must be a JPEG, PNG, or GIF")
    end
  end
end
