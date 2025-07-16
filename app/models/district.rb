class District < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    [ "address", "created_at", "detail_description", "district_overview", "emails", "id", "is_published", "map_embed", "meta_description", "meta_keywords", "meta_title", "name", "phone_numbers", "published_by", "region_id", "social_media_links", "updated_at", "updated_by" ]
  end

  has_one_attached :main_image
  has_many_attached :gallery_images
end
