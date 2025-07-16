class CreatePublications < ActiveRecord::Migration[7.1]
  def change
    create_table :publications, id: :uuid do |t|
      t.string :title, null: false
      t.string :category, null: false
      t.integer :year, null: false
      t.datetime :publish_date, null: false
      t.jsonb :authors, default: []
      t.text :description
      t.integer :download_count, default: 0
      t.boolean :is_new, default: true
      t.string :meta_title
      t.text :meta_description
      t.string :citation_information
      t.jsonb :meta_keywords, default: []
      t.string :status, default: 'draft'
      t.string :published_by
      t.string :updated_by

      t.timestamps
    end

    add_index :publications, :category
    add_index :publications, :year
    add_index :publications, :publish_date
    add_index :publications, :status
  end
end
