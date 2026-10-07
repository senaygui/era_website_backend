class CreateContactMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :contact_messages, id: :uuid do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :subject, null: false
      t.string :department, null: false
      t.text :message, null: false
      t.boolean :consent, null: false, default: false
      t.timestamps
    end
    add_index :contact_messages, :created_at
  end
end
