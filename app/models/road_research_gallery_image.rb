class RoadResearchGalleryImage < ApplicationRecord
  belongs_to :road_research_center
  has_one_attached :image

  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :image_is_present
  validate :image_is_supported

  scope :published, -> { where(is_published: true) }
  scope :ordered, -> { order(:position, :created_at) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[caption created_at id is_published position road_research_center_id title updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[image_attachment image_blob road_research_center]
  end

  private

  def image_is_present
    errors.add(:image, "must be attached") unless image.attached?
  end

  def image_is_supported
    return unless image.attached?

    unless image.blob.content_type.in?(%w[image/jpeg image/png image/webp image/gif])
      errors.add(:image, "must be JPEG, PNG, WebP, or GIF")
    end
    errors.add(:image, "must be smaller than 10 MB") if image.blob.byte_size > 10.megabytes
  end
end
