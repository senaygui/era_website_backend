class Project < ApplicationRecord
  has_many_attached :images
  has_many_attached :documents
  
  # RRC flag is stored as a boolean on projects (no FK association)
  
  validates :title, presence: true
  validates :description, presence: true
  validate :validate_image_type
  validate :validate_document_type

  scope :published, -> { where(is_published: true) }
  scope :completed, -> { published.where(status: 'completed') }
  scope :ongoing, -> { published.where(status: 'ongoing') }
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_location, ->(location) { where(location: location) if location.present? }
  
  # Handle JSON attributes
  before_save :parse_json_attributes
  
  def parse_json_attributes
    # Parse milestones if it's a string
    if milestones.is_a?(String) && !milestones.blank?
      self.milestones = JSON.parse(milestones)
    end
    
    # Parse challenges if it's a string
    if challenges.is_a?(String) && !challenges.blank?
      self.challenges = JSON.parse(challenges)
    end
  rescue JSON::ParserError => e
    errors.add(:base, "Invalid JSON format: #{e.message}")
    throw :abort
  end
  
  # Validate image types
  def validate_image_type
    images.each do |image|
      unless image.content_type.in?(%w[image/jpeg image/png image/gif image/webp])
        errors.add(:images, "#{image.filename} is not a valid image type")
      end
    end
  end
  
  # Validate document types
  def validate_document_type
    documents.each do |document|
      unless document.content_type.in?(%w[application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/zip])
        errors.add(:documents, "#{document.filename} is not a valid document type")
      end
    end
  end
  
  def self.ransackable_attributes(auth_object = nil)
    %w[title description status location contractor project_manager created_at updated_at is_published budget start_date end_date is_road_research_center_project]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[images_attachments documents_attachments]
  end
end
