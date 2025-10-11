class CreateRoadResearchTechnologies < ActiveRecord::Migration[7.0]
  def change
    create_table :road_research_technologies, id: :uuid do |t|
      t.references :road_research_center, null: false, type: :uuid, foreign_key: true, index: { name: "idx_rr_tech_center" }
      t.string :title, null: false
      t.string :category
      t.text :description
      t.boolean :is_published, default: true
      t.string :status, default: "active"
      t.timestamps
    end

    add_index :road_research_technologies, :title
  end
end
