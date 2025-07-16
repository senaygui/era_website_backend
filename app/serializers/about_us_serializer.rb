class AboutUsSerializer < ActiveModel::Serializer
  attributes :id, :title, :subtitle, :description, :mission, :vision, :values, :values_title, :history, :team_description, :team_members, :achievements, :achievements_description, :milestones, :milestones_description, :partners, :is_published, :meta_title, :meta_description, :meta_keywords, :hero_image, :mission_image, :vision_image, :history_image, :org_structure_image, :team_images, :created_at, :updated_at
end
