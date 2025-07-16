class CreateAboutUs < ActiveRecord::Migration[8.0]
  def change
    create_table :about_us, id: :uuid do |t|
      t.string :title, null: false
      t.string :subtitle
      t.text :description, null: false
      t.text :mission
      t.text :vision
      t.text :values
      t.text :history
      t.text :team_description
      t.jsonb :team_members, default: []
      t.jsonb :achievements, default: []
      t.jsonb :milestones, default: []
      t.jsonb :partners, default: []
      t.boolean :is_published, default: true
      t.string :meta_title
      t.text :meta_description
      t.string :meta_keywords

      t.timestamps
    end
  end
end
