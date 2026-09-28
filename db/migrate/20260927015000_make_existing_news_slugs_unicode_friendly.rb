require "set"

class MakeExistingNewsSlugsUnicodeFriendly < ActiveRecord::Migration[8.0]
  def up
    add_column :news, :legacy_slugs, :string, array: true, default: [], null: false

    rows = select_all("SELECT id, title, slug FROM news ORDER BY created_at, id")
    used = Set.new
    rows.each do |row|
      base = FriendlySlug.normalize(row["title"])
      base = "news-#{row['id'].to_s.first(8)}" if base.blank?
      candidate = base
      suffix = 2
      while used.include?(candidate)
        candidate = "#{base}-#{suffix}"
        suffix += 1
      end
      used << candidate
      next if candidate == row["slug"]

      execute <<~SQL.squish
        UPDATE news
        SET slug = #{quote(candidate)}, legacy_slugs = ARRAY[#{quote(row['slug'])}]::varchar[]
        WHERE id = #{quote(row['id'])}
      SQL
    end

    add_index :news, :legacy_slugs, using: :gin
  end

  def down
    remove_column :news, :legacy_slugs
  end
end
