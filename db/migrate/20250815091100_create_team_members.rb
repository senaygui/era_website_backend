class CreateTeamMembers < ActiveRecord::Migration[7.1]
  def change
    create_table :team_members, id: :uuid do |t|
      t.string :name, null: false
      t.string :position
      t.string :job_title
      t.text :description
      # about_us uses UUID primary key, so reference must be UUID and point to :about_us table
      t.references :about_us, type: :uuid, null: false, foreign_key: { to_table: :about_us }

      t.timestamps
    end
  end
end
