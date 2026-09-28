class CreateFeaturedSections < ActiveRecord::Migration[8.0]
  def change
    create_table :featured_sections, id: :uuid do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.string :cta_label
      t.string :cta_url
      t.string :page_keys, array: true, null: false, default: [ "all" ]
      t.string :placement, null: false, default: "after_content"
      t.integer :display_order, null: false, default: 0
      t.boolean :is_published, null: false, default: false

      t.timestamps
    end

    add_index :featured_sections, :page_keys, using: :gin
    add_index :featured_sections, [ :is_published, :placement, :display_order ],
              name: "index_featured_sections_for_display"
  end
end
