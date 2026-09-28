class AboutCoreValue < ApplicationRecord
  belongs_to :about_us
  has_one_attached :image

  validates :title, :description, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :validate_image

  default_scope { order(position: :asc, created_at: :asc) }

  private

  def validate_image
    return unless image.attached?

    errors.add(:image, "must be JPEG, PNG, WebP, or GIF") unless image.content_type.in?(%w[image/jpeg image/png image/webp image/gif])
    errors.add(:image, "must be smaller than 10 MB") if image.byte_size > 10.megabytes
  end
end
