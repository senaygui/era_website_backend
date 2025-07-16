class VacancySerializer < ActiveModel::Serializer
  attributes :id, :title, :department, :location, :job_type, :deadline, :posted_date, :description, :salary, :is_active, :created_at, :updated_at
end
