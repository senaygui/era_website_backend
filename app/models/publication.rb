class Publication < ApplicationRecord
  # ActiveStorage attachments
  has_one_attached :file
  has_one_attached :thumbnail

  def self.ransackable_attributes(auth_object = nil)
    [ "authors", "category", "citation_information", "created_at", "description", "download_count", "id", "is_new", "meta_description", "meta_keywords", "meta_title", "publish_date", "published_by", "status", "title", "updated_at", "updated_by", "year" ]
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
  scope :new_publications, -> { where(is_new: true) }

  # Callbacks
  before_validation :set_year_from_publish_date

  # For Postgres array support (if not using Rails 5+ attributes API)
  # serialize :authors, Array

  private

  def set_year_from_publish_date
    self.year = publish_date.year if publish_date.present?
  end
end
