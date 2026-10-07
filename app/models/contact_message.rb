class ContactMessage < ApplicationRecord
  DEPARTMENTS = {
    "general" => "General Inquiry",
    "projects" => "Projects & Engineering",
    "bids" => "Bids & Tenders",
    "hr" => "Human Resources",
    "media" => "Media & Communications"
  }.freeze

  normalizes :name, :email, :phone, :subject, :message, with: ->(value) { value.strip }

  validates :name, :email, :subject, :department, :message, presence: true
  validates :name, length: { maximum: 100 }
  validates :email, length: { maximum: 254 }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, length: { maximum: 50 }
  validates :subject, length: { maximum: 200 }
  validates :message, length: { maximum: 10_000 }
  validates :department, inclusion: { in: DEPARTMENTS.keys }
  validates :consent, inclusion: { in: [ true ], message: "must be accepted" }

  def self.ransackable_attributes(auth_object = nil)
    %w[name email subject department created_at]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
