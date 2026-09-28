class NewsSerializer < ActiveModel::Serializer
  attributes :id, :slug, :legacy_slugs, :title, :content, :excerpt, :published_date, :is_published, :category, :is_featured, :author, :meta_title, :meta_description, :image, :tags, :meta_keywords, :view_count, :youtube_url, :youtube_embed_url, :created_at, :updated_at
end
