class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.string :status
      t.string :location
      t.decimal :budget
      t.date :start_date
      t.date :end_date
      t.string :contractor
      t.string :project_manager
      t.text :objectives
      t.text :scope
      t.jsonb :milestones, default: []
      t.jsonb :challenges, default: []
      t.boolean :is_published, default: true
      t.string :meta_title
      t.text :meta_description
      t.string :meta_keywords

      t.timestamps
    end

    add_index :projects, :title
    add_index :projects, :status
    add_index :projects, :location
  end
end
