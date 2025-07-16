class AdminUserSerializer < ActiveModel::Serializer
  attributes :id, :email, :first_name, :last_name, :middle_name, :role, :username, :photo, :created_at, :updated_at
end
