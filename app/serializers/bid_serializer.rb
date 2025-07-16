class BidSerializer < ActiveModel::Serializer
  attributes :id, :bid_number, :title, :category, :type_of_bid, :status, :publish_date, :deadline_date, :budget, :funding_source, :description, :eligibility, :contact_person, :contact_email, :contact_phone, :award_status, :awarded_to, :award_date, :contract_value, :is_published, :created_at, :updated_at
end
