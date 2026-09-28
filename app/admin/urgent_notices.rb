ActiveAdmin.register UrgentNotice do
  menu label: "Urgent Notices", priority: 2

  permit_params :notice_title, :notice_short_description, :file, :link_url, :expires_at, :is_published
  config.sort_order = "created_at_desc"

  index do
    selectable_column
    column :notice_title
    column(:notice_short_description) { |notice| truncate(notice.notice_short_description, length: 100) }
    column("Destination") do |notice|
      notice.file.attached? ? notice.file.filename.to_s : notice.link_url
    end
    column :is_published
    column :expires_at
    column :created_at
    actions
  end

  filter :notice_title
  filter :is_published
  filter :created_at
  filter :expires_at

  form do |f|
    f.semantic_errors
    f.inputs "Urgent notice" do
      f.input :notice_title
      f.input :notice_short_description, as: :text, input_html: { rows: 4, class: "aa-plain-text" }
      f.input :file, as: :file,
              hint: f.object.file.attached? ? "Current file: #{f.object.file.filename}" : "Attach a PDF, Word, Excel, ZIP, or image file."
      f.input :link_url, hint: "Use this instead of a file. Internal paths and full HTTP/HTTPS URLs are supported."
      f.input :expires_at, as: :datetime_picker,
              hint: "Optional. The notice disappears automatically at this date and time."
      f.input :is_published
    end
    f.actions
  end

  show do
    attributes_table do
      row :notice_title
      row :notice_short_description
      row :file do |notice|
        link_to(notice.file.filename.to_s, url_for(notice.file), target: "_blank", rel: "noopener") if notice.file.attached?
      end
      row :link_url
      row :is_published
      row :expires_at
      row :created_at
      row :updated_at
    end
  end
end
