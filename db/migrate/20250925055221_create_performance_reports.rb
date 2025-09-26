class CreatePerformanceReports < ActiveRecord::Migration[8.0]
  def change
    create_table :performance_reports, id: :uuid do |t|
      t.string  :title,       null: false
      t.string  :category,    null: false
      t.integer :year,        null: false
      t.datetime :publish_date, null: false
      t.jsonb   :authors,     default: []
      t.text    :description
      t.integer :download_count, default: 0
      t.boolean :is_new,      default: true
      t.string  :meta_title
      t.text    :meta_description
      t.string  :citation_information
      t.jsonb   :meta_keywords, default: []
      t.string  :status,      default: "draft"
      t.string  :published_by
      t.string  :updated_by
      t.timestamps
    end

    add_index :performance_reports, :category
    add_index :performance_reports, :publish_date
    add_index :performance_reports, :status
    add_index :performance_reports, :year
  end
end
