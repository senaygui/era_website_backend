class AddDescriptionFieldsToAboutUs < ActiveRecord::Migration[8.0]
  def change
    add_column :about_us, :achievements_description, :text
    add_column :about_us, :milestones_description, :text
    add_column :about_us, :values_title, :string
  end
end
