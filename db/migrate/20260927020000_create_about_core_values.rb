class CreateAboutCoreValues < ActiveRecord::Migration[8.0]
  def up
    create_table :about_core_values, id: :uuid do |t|
      t.references :about_us, null: false, foreign_key: { to_table: :about_us }, type: :uuid
      t.string :title, null: false
      t.text :description, null: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    add_index :about_core_values, [ :about_us_id, :position ]
    migrate_existing_values
  end

  def down
    drop_table :about_core_values
  end

  private

  def migrate_existing_values
    select_all("SELECT id, values FROM about_us WHERE values IS NOT NULL AND values != ''").each do |row|
      values = JSON.parse(row["values"])
      next unless values.is_a?(Array)

      values.each_with_index do |value, index|
        next unless value.is_a?(Hash) && value["title"].present?

        execute <<~SQL.squish
          INSERT INTO about_core_values (id, about_us_id, title, description, position, created_at, updated_at)
          VALUES (gen_random_uuid(), #{quote(row['id'])}, #{quote(value['title'])},
                  #{quote(value['description'].to_s)}, #{index}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        SQL
      end
    rescue JSON::ParserError
      next
    end
  end
end
