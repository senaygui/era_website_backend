class NewsSerializer < ActiveModel::Serializer
  attributes :id, :title, :content, :excerpt, :published_date, :is_published, :category, :is_featured, :author, :meta_title, :meta_description, :image, :tags, :meta_keywords, :view_count, :created_at, :updated_at
end
