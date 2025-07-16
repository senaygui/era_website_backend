class ApplicantSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :middle_name, :last_name, :email, :phone, :address, :date_of_birth, :gender, :education_level, :years_of_experience, :current_employer, :current_position, :vacancy_id, :status, :cover_letter_text, :notes, :skills, :cv, :cover_letter, :other_documents, :created_at, :updated_at
end
