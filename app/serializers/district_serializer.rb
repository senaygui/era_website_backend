class DistrictSerializer < ActiveModel::Serializer
  attributes :id, :name, :address, :map_embed, :district_overview, :detail_description, :is_published, :meta_title, :meta_description, :published_by, :updated_by, :main_image, :phone_numbers, :emails, :social_media_links, :meta_keywords, :gallery_images, :created_at, :updated_at
end
