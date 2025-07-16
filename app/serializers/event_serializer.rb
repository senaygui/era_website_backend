class EventSerializer < ActiveModel::Serializer
  attributes :id, :event_image, :title, :description, :excerpt, :location, :start_date, :end_date, :time, :event_type, :agenda, :speakers, :capacity, :registration_required, :status, :is_featured, :is_published, :meta_title, :meta_description, :meta_keywords, :created_at, :updated_at
end
