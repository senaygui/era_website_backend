class BuildRoadResearchCenterLandingPage < ActiveRecord::Migration[8.0]
  class MigrationGalleryImage < ActiveRecord::Base
    self.table_name = "road_research_gallery_images"
  end

  class MigrationAttachment < ActiveRecord::Base
    self.table_name = "active_storage_attachments"
  end

  def up
    change_table :road_research_centers, bulk: true do |t|
      t.string :hero_headline
      t.text :hero_subheadline
      t.text :vision
      t.text :mission
      t.text :objectives
      t.text :organizational_structure
      t.string :contact_address
      t.string :contact_phone
      t.string :contact_email
      t.string :contact_hours
      t.string :contact_map_url
    end

    create_table :road_research_gallery_images, id: :uuid do |t|
      t.references :road_research_center, null: false, type: :uuid,
                   foreign_key: true, index: { name: "idx_rrc_gallery_center" }
      t.string :title
      t.text :caption
      t.integer :position, null: false, default: 0
      t.boolean :is_published, null: false, default: true
      t.timestamps
    end

    add_index :road_research_gallery_images,
              [ :road_research_center_id, :position ],
              name: "idx_rrc_gallery_position"

    migrate_existing_gallery_attachments
  end

  def down
    MigrationAttachment.where(
      record_type: "RoadResearchGalleryImage",
      name: "image"
    ).find_each do |attachment|
      gallery = MigrationGalleryImage.find_by(id: attachment.record_id)
      next unless gallery

      attachment.update_columns(
        record_type: "RoadResearchCenter",
        record_id: gallery.road_research_center_id,
        name: "gallery_images"
      )
    end

    drop_table :road_research_gallery_images
    remove_columns :road_research_centers,
                   :hero_headline, :hero_subheadline, :vision, :mission,
                   :objectives, :organizational_structure, :contact_address,
                   :contact_phone, :contact_email, :contact_hours, :contact_map_url
  end

  private

  def migrate_existing_gallery_attachments
    positions = Hash.new(0)
    MigrationAttachment.where(
      record_type: "RoadResearchCenter",
      name: "gallery_images"
    ).find_each do |attachment|
      center_id = attachment.record_id
      gallery = MigrationGalleryImage.create!(
        road_research_center_id: center_id,
        position: positions[center_id],
        is_published: true
      )
      positions[center_id] += 1

      attachment.update_columns(
        record_type: "RoadResearchGalleryImage",
        record_id: gallery.id,
        name: "image"
      )
    end
  end
end
