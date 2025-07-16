class Bid < ApplicationRecord
  has_many_attached :documents
  
  validates :bid_number, presence: true, uniqueness: true
  validates :title, presence: true
  
  # Scopes
  scope :published, -> { where(is_published: true) }
  scope :active, -> { published.where(status: 'active') }
  scope :closed, -> { published.where(status: 'closed') }
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :by_type, ->(type) { where(type_of_bid: type) if type.present? }
  
  # Handle JSON attributes
  before_save :parse_json_attributes
  
  def parse_json_attributes
    # Parse eligibility if it's a string
    if eligibility.is_a?(String) && !eligibility.blank?
      self.eligibility = JSON.parse(eligibility)
    end
  rescue JSON::ParserError => e
    errors.add(:base, "Invalid JSON format: #{e.message}")
    throw :abort
  end
  
  # Ransackable attributes for ActiveAdmin
  def self.ransackable_attributes(auth_object = nil)
    %w[id bid_number title category type_of_bid status publish_date deadline_date 
       budget funding_source description contact_person contact_email contact_phone 
       award_status awarded_to award_date contract_value is_published created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[documents_attachments]
  end
end
