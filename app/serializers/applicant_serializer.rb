class ApplicantSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :middle_name, :last_name, :email, :phone, :status
end