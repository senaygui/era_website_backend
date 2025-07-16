class Applicant < ApplicationRecord
  require "csv"

  # Set UUID as primary key
  self.primary_key = :id

  def self.ransackable_attributes(auth_object = nil)
    [ "address", "cover_letter_text", "created_at", "current_employer", "current_position", "date_of_birth", "education_level", "email", "first_name", "gender", "id", "last_name", "middle_name", "notes", "phone", "skills", "status", "updated_at", "vacancy_id", "years_of_experience" ]
  end
  def self.ransackable_associations(auth_object = nil)
    [ "cover_letter_attachment", "cover_letter_blob", "cv_attachment", "cv_blob", "other_documents_attachments", "other_documents_blobs", "vacancy" ]
  end

  # Associations
  belongs_to :vacancy, foreign_key: "vacancy_id", optional: false

  # Active Storage Attachments
  has_one_attached :cv
  has_one_attached :cover_letter
  has_many_attached :other_documents

  # Validations
  validates :first_name, :last_name, :email, :phone, :address, :date_of_birth,
            :education_level, :years_of_experience, presence: true

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  validates :phone, format: { with: /\A\+?[\d\s-]{10,}\z/ }
  validates :years_of_experience, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  # File validations
  validate :validate_cv_attachment
  validate :validate_cover_letter_attachment

  # Enums
  enum :status, {
    applied: "applied",
    under_review: "under_review",
    shortlisted: "shortlisted",
    interview_scheduled: "interview_scheduled",
    rejected: "rejected",
    hired: "hired"
  }

  enum :gender, {
    male: "male",
    female: "female",
    other: "other",
    prefer_not_to_say: "prefer_not_to_say"
  }

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :for_vacancy, ->(vacancy_id) { where(vacancy_id: vacancy_id) if vacancy_id.present? }

  # Callbacks
  before_validation :normalize_email
  before_validation :normalize_phone

  # Instance methods
  def full_name
    "#{first_name} #{last_name}".strip
  end

  def age
    return nil unless date_of_birth
    now = Time.now.utc.to_date
    now.year - date_of_birth.year - ((now.month > date_of_birth.month ||
      (now.month == date_of_birth.month && now.day >= date_of_birth.day)) ? 0 : 1)
  end

  def cv_filename
    cv.filename.to_s if cv.attached?
  end

  def cover_letter_filename
    cover_letter.filename.to_s if cover_letter.attached?
  end

  # Class method for CSV export
  def self.to_csv
    attributes = %w[id first_name last_name email phone address date_of_birth gender
                   education_level years_of_experience current_employer current_position
                   vacancy_id status created_at updated_at]

    CSV.generate(headers: true) do |csv|
      csv << attributes + [ "full_name", "age", "vacancy_title", "has_cv", "has_cover_letter", "skills" ]

      all.includes(:vacancy).find_each do |applicant|
        row = attributes.map { |attr| applicant.send(attr) }
        # Add calculated and related fields
        row << applicant.full_name
        row << applicant.age
        row << applicant.vacancy.title
        row << applicant.cv.attached?.to_s
        row << applicant.cover_letter.attached?.to_s
        row << applicant.skills.join(", ")

        csv << row
      end
    end
  end

  private

  def normalize_email
    self.email = email.to_s.downcase.strip if email.present?
  end

  def normalize_phone
    return if phone.blank?
    self.phone = phone.gsub(/[^0-9+]/, "")
  end

  def validate_cv_attachment
    return unless cv.attached?

    # Validate file type
    unless cv.content_type.in?(%w[application/pdf application/msword
                                application/vnd.openxmlformats-officedocument.wordprocessingml.document])
      errors.add(:cv, "must be a PDF or Word document")
    end

    # Validate file size (5MB max)
    if cv.byte_size > 5.megabytes
      errors.add(:cv, "should be less than 5MB")
    end
  end

  def validate_cover_letter_attachment
    return unless cover_letter.attached?

    # Validate file type
    unless cover_letter.content_type.in?(%w[application/pdf application/msword
                                         application/vnd.openxmlformats-officedocument.wordprocessingml.document])
      errors.add(:cover_letter, "must be a PDF or Word document")
    end

    # Validate file size (2MB max)
    if cover_letter.byte_size > 2.megabytes
      errors.add(:cover_letter, "should be less than 2MB")
    end
  end
end
