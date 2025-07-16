class CreateApplicants < ActiveRecord::Migration[8.0]
  def change
    create_table :applicants, id: :uuid do |t|
      # Personal Information
      t.string :first_name, null: false
      t.string :middle_name
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :phone, null: false
      t.text :address, null: false
      t.date :date_of_birth, null: false
      t.string :gender
      
      # Professional Information
      t.string :education_level, null: false
      t.integer :years_of_experience, null: false, default: 0
      t.string :current_employer
      t.string :current_position
      t.text :skills, array: true, default: []
      
      # Application Details
      t.uuid :vacancy_id, null: false
      t.string :status, null: false, default: 'applied'
      t.text :cover_letter_text
      t.text :notes
      
      # Timestamps
      t.timestamps
    end
    
    # Add indexes for better query performance
    add_index :applicants, :email, unique: true
    add_index :applicants, :status
    add_index :applicants, :education_level
    add_index :applicants, :years_of_experience
    add_index :applicants, :vacancy_id
    
    # Add index for array column (PostgreSQL specific)
    execute 'CREATE INDEX index_applicants_on_skills ON applicants USING GIN (skills)'
    
    # Add foreign key constraint
    add_foreign_key :applicants, :vacancies, column: :vacancy_id, primary_key: :id, type: :uuid, on_delete: :cascade
  end
end
