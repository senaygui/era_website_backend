class RoadResearchTechnology < ApplicationRecord
  belongs_to :road_research_center

  validates :title, presence: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[title category description status is_published created_at updated_at road_research_center_id]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[road_research_center]
  end
end
