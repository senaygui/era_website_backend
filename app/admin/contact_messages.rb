ActiveAdmin.register ContactMessage do
  actions :index, :show
  config.sort_order = "created_at_desc"
  config.batch_actions = false

  index do
    column :name
    column :email
    column :subject
    column(:department) { |message| ContactMessage::DEPARTMENTS[message.department] }
    column :created_at
    actions
  end

  filter :name
  filter :email
  filter :subject
  filter :department, as: :select, collection: ContactMessage::DEPARTMENTS.map { |key, label| [ label, key ] }
  filter :created_at

  show do
    attributes_table do
      row :name
      row :email
      row :phone
      row :subject
      row(:department) { |message| ContactMessage::DEPARTMENTS[message.department] }
      row(:message) { |message| simple_format(message.message) }
      row :consent
      row :created_at
    end
  end
end
