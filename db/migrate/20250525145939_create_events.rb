class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events, id: :uuid do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.text :excerpt
      t.string :location
      t.datetime :start_date, null: false
      t.datetime :end_date, null: false
      t.string :time
      t.string :event_type, null: false # conference, workshop, seminar, etc.
      t.text :agenda, array: true, default: []
      t.text :speakers, array: true, default: []
      t.integer :capacity
      t.boolean :registration_required, default: true
      t.string :status, default: 'upcoming' # upcoming, ongoing, completed, cancelled
      t.boolean :is_featured, default: false
      t.boolean :is_published, default: true
      t.string :slug, null: false
      t.string :meta_title
      t.text :meta_description
      t.string :meta_keywords

      t.timestamps
    end

    add_index :events, :slug, unique: true
    add_index :events, :event_type
    add_index :events, :status
    add_index :events, :start_date
    add_index :events, :is_featured
    add_index :events, :is_published
  end
end
