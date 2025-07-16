class CreateVacancies < ActiveRecord::Migration[8.0]
  def change
    create_table :vacancies, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :title, null: false
      t.string :department, null: false
      t.string :location, null: false
      t.string :job_type, null: false  # e.g., "Full-Time", "Contract", etc.
      t.date :deadline, null: false
      t.date :posted_date, null: false
      t.text :description, null: false
      t.jsonb :requirements, default: []  # Array of requirement strings
      t.jsonb :responsibilities, default: []  # Array of responsibility strings
      t.string :salary, null: false
      t.jsonb :benefits, default: []  # Array of benefit strings
      t.boolean :is_published, default: true
      t.integer :position  # For manual ordering

      t.timestamps
    end

    add_index :vacancies, :title
    add_index :vacancies, :department
    add_index :vacancies, :location
    add_index :vacancies, :job_type
    add_index :vacancies, :deadline
    add_index :vacancies, :is_published
  end
end
