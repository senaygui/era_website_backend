class PublicationSerializer < ActiveModel::Serializer
  attributes :id, :title, :category, :year, :publish_date, :description, :download_count, :is_new, :meta_title, :meta_description, :status, :published_by, :updated_by, :authors, :file, :thumbnail, :created_at, :updated_at
end
