class PerformanceReport < ApplicationRecord
  # ActiveStorage attachments
  has_one_attached :file
  has_one_attached :thumbnail

  def self.ransackable_attributes(auth_object = nil)
    [
      "authors", "category", "citation_information", "created_at", "description",
      "download_count", "id", "is_new", "meta_description", "meta_keywords",
      "meta_title", "publish_date", "published_by", "status", "title",
      "updated_at", "updated_by", "year"
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    ["file_attachment", "file_blob", "thumbnail_attachment", "thumbnail_blob"]
  end

  # Validations
  validates :title, presence: true
  validates :category, presence: true
  validates :year, presence: true, numericality: { only_integer: true }
  validates :publish_date, presence: true
  validates :status, inclusion: { in: %w[draft published archived] }
  validates :file, presence: true

  # Scopes
  scope :published, -> { where(status: "published") }
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :by_year, ->(year) { where(year: year) if year.present? }
  scope :recent, -> { order(publish_date: :desc) }
  scope :most_downloaded, -> { order(download_count: :desc) }
  scope :new_items, -> { where(is_new: true) }

  # Callbacks
  before_validation :set_year_from_publish_date
  before_validation :normalize_authors

  private

  def set_year_from_publish_date
    self.year = publish_date.year if publish_date.present?
  end

  # Ensure authors is always stored as an array of strings
  def normalize_authors
    value = self[:authors]
    if value.is_a?(String)
      str = value.strip
      if str.start_with?('[')
        begin
          parsed = JSON.parse(str)
          value = parsed
        rescue JSON::ParserError
          value = str
        end
      end
      value = value.split(',').map(&:strip) if value.is_a?(String)
    end
    value = Array(value).reject(&:blank?).map(&:to_s)
    self[:authors] = value
  end
end
