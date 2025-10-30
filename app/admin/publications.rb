ActiveAdmin.register Publication do
  menu parent: "Resources", priority: 1
  permit_params :thumbnail, :title, :file, :category, :year, :publish_date, :description, :download_count, :is_new, :meta_title, :meta_description, :status, :published_by, :updated_by, authors: [], documents: []

  # Ensure authors param is normalized for both create and update
  controller do
    def create
      normalize_authors_param
      docs = params[:publication].delete(:documents)
      super do |success, _failure|
        if success && docs.present?
          Array(docs).each { |io| resource.documents.attach(io) }
        end
      end
    end

    def update
      normalize_authors_param
      docs = params[:publication].delete(:documents)
      super do |success, _failure|
        if success && docs.present?
          Array(docs).each { |io| resource.documents.attach(io) }
        end
      end
    end

    private

    def normalize_authors_param
      a = params.dig(:publication, :authors)
      return if a.nil?
      params[:publication][:authors] = if a.is_a?(String)
        a.split(',').map(&:strip).reject(&:blank?)
      else
        Array(a).reject(&:blank?)
      end
    end
  end
  
  member_action :remove_document, method: :post do
    att = resource.documents.attachments.find_by(id: params[:attachment_id])
    if att
      att.purge
      redirect_to resource_path, notice: "Document removed successfully."
    else
      redirect_to resource_path, alert: "Document not found."
    end
  end
  # Filters
  filter :title
  filter :category
  filter :year
  filter :publish_date
  filter :is_new
  filter :status, as: :select, collection: %w[draft published archived]

  index do
    selectable_column
    id_column
    column :title
    column :category
    column :year
    column :publish_date
    column :authors do |pub|
      pub.authors&.join(", ")
    end
    column :is_new
    column :download_count
    column :status
    column :thumbnail do |pub|
      if pub.thumbnail.attached?
        image_tag url_for(pub.thumbnail), height: 50
      end
    end
    actions
  end

  show do
    attributes_table do
      row :title
      row :category
      row :year
      row :publish_date
      row :authors do |pub|
        pub.authors&.join(", ")
      end
      row :description
      row :is_new
      row :download_count
      row :meta_title
      row :meta_description
      row :status
      row :published_by
      row :updated_by
      row :documents do |project|
        if project.documents.attached?
          ul do
            project.documents.each do |doc|
              li do
                span doc.filename.to_s
                span " "
                span link_to("Download", url_for(doc), target: "_blank")
                span " "
                span link_to("Delete", remove_document_admin_publication_path(project, attachment_id: doc.id), method: :post, data: { confirm: "Delete this document?" })
              end
            end
          end
        end
      end
      row :thumbnail do |pub|
        if pub.thumbnail.attached?
          image_tag url_for(pub.thumbnail), height: 100
        end
      end
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :title
      f.input :category
      f.input :publish_date, as: :datetime_picker
      f.input :authors, as: :select, multiple: true, collection: AdminUser.all.map { |u| [u.full_name, u.full_name] }
      f.input :description
      f.input :is_new
      f.input :meta_title
      f.input :meta_description
      f.input :status, as: :select, collection: %w[draft published archived]
      f.input :published_by
      f.input :updated_by
      f.input :documents, as: :file, input_html: { multiple: true }
      f.input :thumbnail, as: :file, hint: (f.object.thumbnail.attached? ? image_tag(url_for(f.object.thumbnail), height: 100) : nil)
    end
    f.actions
  end
end
