ActiveAdmin.register Bid do
  permit_params :bid_number, :title, :category, :type_of_bid, :status,
                :publish_date, :deadline_date, :budget, :funding_source,
                :description, :eligibility, :contact_person, :contact_email,
                :contact_phone, :award_status, :awarded_to, :award_date,
                :contract_value, :is_published, documents: []

  
                member_action :update, method: :post do
                  resource.assign_attributes(permitted_params[:bid])
                  if resource.save
                    redirect_to resource_path, notice: "Bid was successfully updated."
                  else
                    render :edit
                  end
                end
  index do
    selectable_column
    id_column
    column :bid_number
    column :title
    column :category
    column :type_of_bid
    column :status
    column :publish_date
    column :deadline_date
    column :is_published
    column :created_at
    actions
  end

  filter :bid_number
  filter :title
  filter :category
  filter :type_of_bid
  filter :status
  filter :publish_date
  filter :deadline_date
  filter :is_published
  filter :created_at

  form do |f|
    f.inputs do
      f.input :bid_number
      f.input :title
      f.input :category, as: :select, collection: [
        "Road Construction",
        "Road Rehabilitation",
        "Bridge Construction",
        "Consultancy Services",
        "Road Maintenance",
        "Goods"
      ]
      f.input :type_of_bid, as: :select, collection: [
        "International Competitive Bidding",
        "National Competitive Bidding",
        "Request for Proposals",
        "Direct Procurement"
      ]
      f.input :status, as: :select, collection: [ "active", "closed" ]
      f.input :publish_date, as: :datepicker
      f.input :deadline_date, as: :datepicker
      f.input :budget
      f.input :funding_source
      f.input :description, as: :text
      f.input :eligibility, as: :text, input_html: {
        value: f.object.eligibility.to_json,
        hint: 'JSON array of eligibility criteria, e.g., ["Criterion 1", "Criterion 2"]'
      }
      f.input :contact_person
      f.input :contact_email
      f.input :contact_phone
      f.input :award_status, as: :select, collection: [ "", "awarded", "cancelled" ]
      f.input :awarded_to
      f.input :award_date, as: :datepicker
      f.input :contract_value
      f.input :documents, as: :file, input_html: { multiple: true }
      f.input :is_published
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :bid_number
      row :title
      row :category
      row :type_of_bid
      row :status
      row :publish_date
      row :deadline_date
      row :budget
      row :funding_source
      row :description
      row :eligibility do |bid|
        eligibility_data = if bid.eligibility.is_a?(String)
          begin
            JSON.parse(bid.eligibility)
          rescue JSON::ParserError
            []
          end
        else
          bid.eligibility
        end

        if eligibility_data.is_a?(Array) && eligibility_data.any?
          ul do
            eligibility_data.each do |item|
              li do
                span { item.to_s }
              end
            end
          end
        else
          span { "No eligibility criteria" }
        end
      end
      row :contact_person
      row :contact_email
      row :contact_phone
      row :award_status
      row :awarded_to
      row :award_date
      row :contract_value
      row :documents do |bid|
        if bid.documents.attached?
          ul do
            bid.documents.each do |doc|
              li do
                span doc.filename.to_s
                span link_to "Download Document", url_for(doc), target: "_blank"
              end
            end
          end
        end
      end
      row :is_published
      row :created_at
      row :updated_at
    end
  end
end
