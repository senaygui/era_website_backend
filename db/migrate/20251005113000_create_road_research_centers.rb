class CreateRoadResearchCenters < ActiveRecord::Migration[7.0]
  def change
    create_table :road_research_centers, id: :uuid do |t|
      t.string :title, null: false
      t.text :about, null: false
      t.boolean :is_published, default: true
      t.string :meta_title
      t.text :meta_description
      t.string :meta_keywords
      t.timestamps
    end

    add_index :road_research_centers, :title
    add_index :road_research_centers, :is_published
  end
end
