class BackfillPlainTextAboutCoreValues < ActiveRecord::Migration[8.0]
  def up
    select_all("SELECT id, values FROM about_us WHERE values IS NOT NULL AND values != ''").each do |row|
      next if select_value("SELECT 1 FROM about_core_values WHERE about_us_id = #{quote(row['id'])} LIMIT 1")

      row["values"].to_s.lines.map(&:strip).reject(&:blank?).each_slice(2).with_index do |(title, description), index|
        next if title.blank?

        execute <<~SQL.squish
          INSERT INTO about_core_values (id, about_us_id, title, description, position, created_at, updated_at)
          VALUES (gen_random_uuid(), #{quote(row['id'])}, #{quote(title)}, #{quote(description.to_s)},
                  #{index}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        SQL
      end
    end
  end

  def down
    execute "DELETE FROM about_core_values WHERE NOT EXISTS (SELECT 1 FROM active_storage_attachments WHERE record_type = 'AboutCoreValue' AND record_id = about_core_values.id)"
  end
end
