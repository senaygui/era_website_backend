ActiveAdmin.register AdminUser do
  permit_params :email, :password, :password_confirmation, :first_name, :last_name,
                :middle_name, :role, :username, :photo

  controller do
    def update_resource(object, attributes)
      if attributes.first[:password].present?
        object.update(*attributes)
      else
        object.update_without_password(*attributes)
      end
    end
  end

  index do
    selectable_column
    column "Full Name" do |n|
      "#{n.first_name} #{n.middle_name} #{n.last_name}"
    end
    column :email
    column :role
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :email
  filter :username
  filter :role
  filter :created_at
  filter :current_sign_in_at
  filter :sign_in_count

  form do |f|
    f.inputs "Administration Account" do
      f.input :first_name
      f.input :middle_name
      f.input :last_name
      f.input :username
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :role, as: :select, collection: %w[Admin author publisher]
      f.input :photo, as: :file
    end
    f.actions
  end

  show title: proc { |admin_user| admin_user.first_name + " " + admin_user.last_name } do
    panel "Admin User Information" do
      attributes_table_for admin_user do
        row "Photo" do |pt|
          image_tag pt.photo.variant(resize_to_limit: [ 150, 150 ]) if pt.photo.attached?
        end
        row :first_name
        row :middle_name
        row :last_name
        row :username
        row :email
        row :role
        row :sign_in_count
        row :current_sign_in_at
        row :last_sign_in_at
        row :current_sign_in_ip
        row :last_sign_in_ip
        row :created_at
        row :updated_at
      end
    end
  end
end
