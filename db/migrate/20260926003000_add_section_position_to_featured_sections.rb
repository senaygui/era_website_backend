class AddSectionPositionToFeaturedSections < ActiveRecord::Migration[8.0]
  def change
    add_column :featured_sections, :section_position, :integer, null: false, default: 1
    add_index :featured_sections, [ :is_published, :section_position, :display_order ],
              name: "index_featured_sections_by_page_position"
  end
end
