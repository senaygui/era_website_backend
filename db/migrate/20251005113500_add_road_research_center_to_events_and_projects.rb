class AddRoadResearchCenterToEventsAndProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :is_road_research_center_event, :boolean, default: false
    add_index :events, :is_road_research_center_event

    add_column :projects, :is_road_research_center_project, :boolean, default: false
    add_index :projects, :is_road_research_center_project
  end
end
