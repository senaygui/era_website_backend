class Vacancy < ApplicationRecord
  # Set UUID as primary key
  self.primary_key = :id
  
  # Associations
  has_many :applicants, foreign_key: 'vacancy_id', dependent: :destroy
  
  # Validations
  validates :title, presence: true, length: { maximum: 255 }
  validates :department, presence: true, length: { maximum: 255 }
  validates :location, presence: true, length: { maximum: 255 }
  validates :job_type, presence: true, length: { maximum: 100 }
  validates :deadline, presence: true
  validates :posted_date, presence: true
  validates :description, presence: true
  validates :salary, presence: true, length: { maximum: 255 }
  
  # JSON validations
  validate :validate_requirements_format
  validate :validate_responsibilities_format
  validate :validate_benefits_format
  
  # Scopes
  scope :published, -> { where(is_published: true) }
  scope :active, -> { published.where('deadline >= ?', Date.current) }
  scope :expired, -> { published.where('deadline < ?', Date.current) }
  scope :by_department, ->(dept) { where(department: dept) if dept.present? }
  scope :by_location, ->(loc) { where(location: loc) if loc.present? }
  scope :by_job_type, ->(type) { where(job_type: type) if type.present? }
  scope :recent, -> { order(posted_date: :desc) }
  scope :ordered, -> { order(position: :asc, posted_date: :desc) }
  
  # Application statistics
  def application_stats
    {
      total_applicants: applicants.count,
      new_applicants: applicants.where(status: 'applied').count,
      under_review: applicants.where(status: 'under_review').count,
      shortlisted: applicants.where(status: 'shortlisted').count,
      interview_scheduled: applicants.where(status: 'interview_scheduled').count,
      hired: applicants.where(status: 'hired').count,
      rejected: applicants.where(status: 'rejected').count
    }
  end
  
  # For ActiveAdmin
  def self.ransackable_attributes(auth_object = nil)
    %w[title department location job_type deadline posted_date is_published created_at updated_at]
  end
  
  def self.ransackable_associations(auth_object = nil)
    []
  end
  
  # Instance methods
  def active?
    is_published? && deadline >= Date.current
  end
  
  def expired?
    deadline < Date.current
  end
  
  private
  
  def validate_requirements_format
    return if requirements.is_a?(Array) && requirements.all? { |r| r.is_a?(String) }
    errors.add(:requirements, 'must be an array of strings')
  end
  
  def validate_responsibilities_format
    return if responsibilities.is_a?(Array) && responsibilities.all? { |r| r.is_a?(String) }
    errors.add(:responsibilities, 'must be an array of strings')
  end
  
  def validate_benefits_format
    return if benefits.is_a?(Array) && benefits.all? { |b| b.is_a?(String) }
    errors.add(:benefits, 'must be an array of strings')
  end
end
