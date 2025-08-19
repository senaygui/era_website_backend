class TeamMember < ApplicationRecord
  belongs_to :about_us

  has_one_attached :image

  validates :name, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["id", "name", "position", "job_title", "description", "about_us_id", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["about_us", "image_attachment", "image_blob"]
  end
end
