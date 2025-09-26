class Bid < ApplicationRecord
  has_many_attached :documents
  
  validates :bid_number, presence: true, uniqueness: true
  validates :title, presence: true
  
  # Scopes
  scope :published, -> { where(is_published: true) }
  # Time-aware scopes: a bid is considered closed if its deadline_date has passed
  scope :active, -> {
    published.where(
      "(deadline_date IS NULL OR deadline_date >= ?) AND (status IS NULL OR status = '' OR status = 'active')",
      Date.current
    )
  }
  scope :closed, -> {
    published.where(
      "(deadline_date IS NOT NULL AND deadline_date < ?) OR status = 'closed'",
      Date.current
    )
  }
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

  # Computed helpers
  def computed_status
    if deadline_date.present? && deadline_date < Date.current
      'closed'
    else
      status.presence || 'active'
    end
  end
end
