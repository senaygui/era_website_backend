ActiveAdmin.register News do

  menu parent: "Events & News", priority: 1
  permit_params :title, :content, :excerpt, :published_date, :is_published,
                :category, :is_featured, :author, :meta_title, :meta_description,
                :image, :tag_list, :meta_keywords

  # Rely on default update action

  index do
    selectable_column
    id_column
    column :title
    column :category
    column :published_date
    column :is_published
    column :is_featured
    column :view_count
    column :created_at
    column :image do |news|
      if news.image.attached?
        image_tag url_for(news.image.variant(resize_to_limit: [ 100, 100 ]))
      end
    end
    actions
  end

  filter :title
  filter :category
  filter :published_date
  filter :is_published
  filter :is_featured
  filter :created_at

  form do |f|
    f.inputs "News Details" do
      f.input :title
      f.input :content, as: :text, input_html: { rows: 10 }
      f.input :excerpt, as: :text, input_html: { rows: 3 }
      f.input :image, as: :file
      f.input :published_date, as: :date_picker
      f.input :category
      f.input :tag_list, input_html: { value: f.object.tag_list.join(', ') }
      f.input :is_published
      f.input :is_featured
      f.input :author
    end

    f.inputs "SEO Settings" do
      f.input :meta_title
      f.input :meta_description, as: :text, input_html: { rows: 3 }
      f.input :meta_keywords
    end

    f.actions
  end

  show do
    attributes_table do
      row :title
      row :content
      row :excerpt
      row :image do |news|
        if news.image.attached?
          span image_tag(news.image, size: "150x150", class: "img-corner")
        end
      end
      row :published_date
      row :category
      row :tags
      row :is_published
      row :is_featured
      row :view_count
      row :author
      row :meta_title
      row :meta_description
      row :meta_keywords
      row :created_at
      row :updated_at
    end
  end
end
