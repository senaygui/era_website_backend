class CreateRoadResearchLaboratoryServices < ActiveRecord::Migration[7.0]
  def change
    create_table :road_research_laboratory_services, id: :uuid do |t|
      t.references :road_research_center, null: false, type: :uuid, foreign_key: true, index: { name: "idx_rr_lab_center" }
      t.string :title, null: false
      t.string :category
      t.text :description
      t.boolean :is_published, default: true
      t.string :status, default: "active"
      t.timestamps
    end

    add_index :road_research_laboratory_services, :title
  end
end
