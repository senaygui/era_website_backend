class AddSingletonConstraintToRoadResearchCenters < ActiveRecord::Migration[7.0]
  def up
    add_column :road_research_centers, :singleton_key, :integer, null: false, default: 1
    add_index :road_research_centers, :singleton_key, unique: true, name: "idx_rrc_singleton"
  end

  def down
    remove_index :road_research_centers, name: "idx_rrc_singleton"
    remove_column :road_research_centers, :singleton_key
  end
end
