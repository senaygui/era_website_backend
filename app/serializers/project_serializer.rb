class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :status, :location, :budget, :start_date, :end_date, :contractor, :project_manager, :objectives, :scope, :milestones, :challenges, :is_published, :meta_title, :meta_description, :meta_keywords, :images, :documents, :created_at, :updated_at
end
