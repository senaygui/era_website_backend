class RoadResearchCenter < ApplicationRecord
  # Associations
  has_many :road_research_technologies, dependent: :destroy
  has_many :road_research_laboratory_services, dependent: :destroy
  has_many_attached :gallery_images

  accepts_nested_attributes_for :road_research_technologies, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :road_research_laboratory_services, allow_destroy: true, reject_if: :all_blank

  # Validations
  validates :title, presence: true
  validates :about, presence: true
  validates :singleton_key, inclusion: { in: [ 1 ] }, if: :singleton_key_attribute?
  validates :singleton_key, uniqueness: true, if: :singleton_key_attribute?

  # Ensure singleton_key always set to 1
  before_validation :ensure_singleton_key, if: :singleton_key_attribute?

  # Admin/Ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[title about is_published meta_title meta_description meta_keywords created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[road_research_technologies road_research_laboratory_services gallery_images_attachments gallery_images_blobs]
  end

  # Convenience accessor to get-or-create the singleton record
  def self.instance
    first_or_create!(title: "Road Research Center", about: "Road Research Center content")
  end

  private

  def ensure_singleton_key
    self.singleton_key ||= 1
  end

  def singleton_key_attribute?
    has_attribute?(:singleton_key)
  end
end
