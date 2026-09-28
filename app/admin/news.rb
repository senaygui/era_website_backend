ActiveAdmin.register News do
  menu parent: "Events & News", priority: 1
  permit_params :title, :content, :excerpt, :published_date, :is_published,
                :category, :is_featured, :author, :meta_title, :meta_description,
                :image, :tag_list, :meta_keywords, :youtube_url

  # Rely on default update action

  index do
    selectable_column
    column(:title)    { |r| content_tag(:span, truncate(r.title.to_s, length: 60),   title: r.title.to_s) }
    column(:category) { |r| content_tag(:span, truncate(r.category.to_s, length: 40), title: r.category.to_s) }
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

  form html: { class: "news-editor-form" } do |f|
    f.semantic_errors

    f.inputs "News Details" do
      f.input :title
      f.input :content,
              as: :tiptap,
              hint: "Use the visual editor or select HTML to edit the source of existing content."
      f.input :excerpt,
              as: :text,
              label: "Short description",
              hint: "Maximum 256 characters. Leave blank when creating to generate it from the content.",
              input_html: { rows: 4, maxlength: 256, class: "aa-plain-text" }
      image_hint = if f.object.image.attached?
        image_tag(
          rails_blob_path(f.object.image, only_path: true),
          alt: "Current news image",
          class: "current-news-image-preview"
        )
      else
        "Upload the main news image."
      end
      f.input :image,
              as: :file,
              label: f.object.image.attached? ? "Replace image" : "Main image",
              input_html: { accept: "image/jpeg,image/png,image/webp,image/gif" },
              hint: image_hint
      f.input :youtube_url,
              label: "YouTube video URL",
              hint: "Optional. Featured news will play this video in the homepage hero. Supports youtube.com and youtu.be URLs."
      f.input :published_date, as: :date_picker
      f.input :category,
              as: :select,
              collection: News::CATEGORIES,
              include_blank: "Select a category"
      f.input :tag_list,
              hint: "Separate multiple tags with commas. Example: road safety, bridge, maintenance",
              input_html: {
                value: f.object.tag_list.join(", "),
                placeholder: "road safety, bridge, maintenance"
              }
      f.input :is_published
      f.input :is_featured
      f.input :author
    end

    f.inputs "SEO Settings" do
      f.input :meta_title, hint: "Leave blank when creating to use the news title."
      f.input :meta_description,
              as: :text,
              hint: "Leave blank when creating to use the short description or content.",
              input_html: { rows: 3, class: "aa-plain-text" }
      f.input :meta_keywords,
              hint: "Leave blank when creating to use the category and tag list."
    end

    f.actions
  end

  show do
    attributes_table do
      row :title
      row :content
      row("Short description") { |news| news.excerpt }
      row :image do |news|
        if news.image.attached?
          span image_tag(news.image, size: "150x150", class: "img-corner")
        end
      end
      row :youtube_url
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
