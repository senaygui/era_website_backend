class AddExpiresAtToUrgentNotices < ActiveRecord::Migration[8.0]
  def change
    add_column :urgent_notices, :expires_at, :datetime
    add_index :urgent_notices, :expires_at
  end
end
