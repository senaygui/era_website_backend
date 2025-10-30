  # def require_documents_on_create
  #   errors.add(:documents, "can't be blank") unless documents.attached?
  # end
class Publication < ApplicationRecord
  # ActiveStorage attachments
  has_many_attached :documents
  has_one_attached :thumbnail

  def self.ransackable_attributes(auth_object = nil)
    [ "authors", "category", "citation_information", "created_at", "description", "download_count", "id", "is_new", "meta_description", "meta_keywords", "meta_title", "publish_date", "published_by", "status", "title", "updated_at", "updated_by", "year" ]
  end
  def self.ransackable_associations(auth_object = nil)
    ["documents_attachments", "documents_blobs", "thumbnail_attachment", "thumbnail_blob"]
  end

  # Validations
  validates :title, presence: true
  validates :category, presence: true
  validates :year, presence: true, numericality: { only_integer: true }
  validates :publish_date, presence: true
  validates :status, inclusion: { in: %w[draft published archived] }
  # validate :require_documents_on_create, on: :create

  # Scopes
  scope :published, -> { where(status: "published") }
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :by_year, ->(year) { where(year: year) if year.present? }
  scope :recent, -> { order(publish_date: :desc) }
  scope :most_downloaded, -> { order(download_count: :desc) }
  scope :new_publications, -> { where(is_new: true) }

  # Callbacks
  before_validation :set_year_from_publish_date
  before_validation :normalize_authors

  # For Postgres array support (if not using Rails 5+ attributes API)
  # serialize :authors, Array

  private

  def set_year_from_publish_date
    self.year = publish_date.year if publish_date.present?
  end

  # Ensure authors is always stored as an array of strings
  def normalize_authors
    value = self[:authors]
    # Allow form submissions that pass authors as comma-separated string
    if value.is_a?(String)
      str = value.strip
      # Try JSON parse first if it looks like a JSON array
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
