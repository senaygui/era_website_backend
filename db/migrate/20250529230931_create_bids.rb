class CreateBids < ActiveRecord::Migration[8.0]
  def change
    create_table :bids, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :bid_number, null: false  # e.g., "ICB-2025-01"
      t.string :title, null: false
      t.string :category   # e.g., "Road Construction", "Consultancy Services"
      t.string :type_of_bid  # e.g., "International Competitive Bidding", "National Competitive Bidding"
      t.string :status, default: "active"  # active, closed
      t.date :publish_date
      t.date :deadline_date
      t.string :budget
      t.string :funding_source
      t.text :description
      t.jsonb :eligibility, default: []  # Array of eligibility criteria
      t.string :contact_person
      t.string :contact_email
      t.string :contact_phone
      t.string :award_status  # awarded, cancelled, etc.
      t.string :awarded_to
      t.date :award_date
      t.string :contract_value
      t.boolean :is_published, default: true

      t.timestamps
    end

    add_index :bids, :bid_number, unique: true
    add_index :bids, :status
    add_index :bids, :category
    add_index :bids, :type_of_bid
    add_index :bids, :publish_date
    add_index :bids, :deadline_date
  end
end
