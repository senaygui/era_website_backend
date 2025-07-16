ActiveAdmin.register Publication do
  permit_params :title, :category, :year, :publish_date, :description, :download_count, :is_new, :meta_title, :meta_description, :status, :published_by, :updated_by, authors: [], file: [], thumbnail: []

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
    column :file do |pub|
      if pub.file.attached?
        link_to "Download", url_for(pub.file), target: "_blank"
      end
    end
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
      row :file do |pub|
        if pub.file.attached?
          link_to "Download", url_for(pub.file), target: "_blank"
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
      f.input :authors, as: :tags, collection: f.object.authors || []
      f.input :description
      f.input :is_new
      f.input :meta_title
      f.input :meta_description
      f.input :status, as: :select, collection: %w[draft published archived]
      f.input :published_by
      f.input :updated_by
      f.input :file, as: :file, hint: (f.object.file.attached? ? link_to("Download", url_for(f.object.file), target: "_blank") : nil)
      f.input :thumbnail, as: :file, hint: (f.object.thumbnail.attached? ? image_tag(url_for(f.object.thumbnail), height: 100) : nil)
    end
    f.actions
  end
end
