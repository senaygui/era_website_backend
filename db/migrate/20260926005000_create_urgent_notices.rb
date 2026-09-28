class CreateUrgentNotices < ActiveRecord::Migration[8.0]
  def change
    create_table :urgent_notices, id: :uuid do |t|
      t.string :notice_title, null: false
      t.text :notice_short_description, null: false
      t.string :link_url
      t.boolean :is_published, null: false, default: true

      t.timestamps
    end

    add_index :urgent_notices, [ :is_published, :created_at ]
  end
end
