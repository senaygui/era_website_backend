require "set"

class AddFriendlySlugsToProjectsAndDistricts < ActiveRecord::Migration[8.0]
  def up
    add_column :projects, :slug, :string
    add_column :districts, :slug, :string

    backfill_slugs(:projects, :title, "project")
    backfill_slugs(:districts, :name, "district")

    change_column_null :projects, :slug, false
    change_column_null :districts, :slug, false
    add_index :projects, :slug, unique: true
    add_index :districts, :slug, unique: true
  end

  def down
    remove_column :projects, :slug
    remove_column :districts, :slug
  end

  private

  def backfill_slugs(table, source_column, fallback)
    rows = select_all("SELECT id, #{quote_column_name(source_column)} FROM #{quote_table_name(table)} ORDER BY created_at, id")
    used = Set.new

    rows.each do |row|
      base = row[source_column.to_s].to_s.parameterize
      base = "#{fallback}-#{row['id'].to_s.first(8)}" if base.blank?
      candidate = base
      suffix = 2
      while used.include?(candidate)
        candidate = "#{base}-#{suffix}"
        suffix += 1
      end
      used << candidate

      execute <<~SQL.squish
        UPDATE #{quote_table_name(table)}
        SET slug = #{quote(candidate)}
        WHERE id = #{quote(row['id'])}
      SQL
    end
  end
end
