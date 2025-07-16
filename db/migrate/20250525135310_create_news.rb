class CreateNews < ActiveRecord::Migration[8.0]
  def change
    create_table :news, id: :uuid do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.text :excerpt
      t.date :published_date
      t.boolean :is_published, default: false
      t.string :slug, null: false
      t.string :category
      t.string :tags, array: true, default: []
      t.boolean :is_featured, default: false
      t.integer :view_count, default: 0
      t.string :author
      t.string :meta_title
      t.text :meta_description
      t.string :meta_keywords, array: true, default: []

      t.timestamps
    end

    add_index :news, :slug, unique: true
    add_index :news, :category
    add_index :news, :published_date
    add_index :news, :is_published
    add_index :news, :is_featured
  end
end
