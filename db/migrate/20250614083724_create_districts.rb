class CreateDistricts < ActiveRecord::Migration[8.0]
  def change
    create_table :districts, id: :uuid do |t|
      t.string :name, null: false
      t.string :address
      t.text :map_embed
      t.jsonb :phone_numbers, default: []  # Change to JSONB for phone numbers
      t.jsonb :emails, default: []  # Change to JSONB for emails
      t.jsonb :social_media_links, default: []  # Change to JSONB for social media links
      t.text :district_overview
      t.text :detail_description
      t.boolean :is_published, default: false
      t.string :meta_title
      t.text :meta_description
      t.jsonb :meta_keywords, default: []  # Change to JSONB for meta keywords
      t.string :published_by
      t.string :updated_by

      t.timestamps
    end

    add_index :districts, :name, unique: true
    add_index :districts, :is_published
  end
end
