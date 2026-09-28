class District < ApplicationRecord
  include SeoMetadataSync
  include FriendlySlug

  has_friendly_slug source: :name, fallback: "district"

  syncs_seo_metadata title: :name,
                      description: [ :district_overview, :detail_description ],
                      keywords: [ :name, :address ]

  def self.ransackable_attributes(auth_object = nil)
    [ "address", "created_at", "detail_description", "district_overview", "emails", "id", "is_published", "map_embed", "meta_description", "meta_keywords", "meta_title", "name", "phone_numbers", "published_by", "region_id", "slug", "social_media_links", "updated_at", "updated_by" ]
  end

  has_one_attached :main_image
  has_many_attached :gallery_images
end
