ActiveAdmin.register FeaturedSection do
  menu label: "Featured Sections", priority: 3

  permit_params :title, :description, :main_photo, :cta_label, :cta_url,
                :section_position, :display_order, :is_published, page_keys: []

  config.sort_order = "section_position_asc"

  index do
    selectable_column
    column :title
    column("Pages") do |section|
      labels = FeaturedSection::PAGE_OPTIONS.invert
      section.page_keys.map { |key| labels[key] || key }.join(", ")
    end
    column :section_position
    column :display_order
    column :is_published
    column :main_photo do |section|
      image_tag(url_for(section.main_photo.variant(resize_to_limit: [ 120, 80 ]))) if section.main_photo.attached?
    end
    column :updated_at
    actions
  end

  filter :title
  filter :section_position
  filter :is_published
  filter :updated_at

  form do |f|
    f.semantic_errors

    f.inputs "Featured section content" do
      f.input :title
      f.input :description, as: :tiptap
      f.input :main_photo, as: :file,
              hint: f.object.main_photo.attached? ? image_tag(url_for(f.object.main_photo.variant(resize_to_limit: [ 320, 180 ]))) : "Required"
      f.input :cta_label, label: "CTA button label"
      f.input :cta_url, label: "CTA URL", hint: "Use /about for an internal page or a full https:// URL."
    end

    f.inputs "Display settings" do
      f.input :page_keys,
              as: :check_boxes,
              collection: FeaturedSection::PAGE_OPTIONS,
              label: "Show on pages",
              hint: "Choose All pages or one or more specific pages."
      f.input :section_position,
              label: "Insert after page section",
              hint: "1 places it after the first existing page section, 2 after the second, and so on. Use 0 to place it first."
      f.input :display_order,
              hint: "When multiple featured sections use the same position, lower numbers appear first."
      f.input :is_published
    end

    f.actions
  end

  show do
    attributes_table do
      row :title
      row :description do |section|
        div sanitize(section.description.to_s)
      end
      row :main_photo do |section|
        image_tag(section.main_photo, style: "max-width: 640px; height: auto;") if section.main_photo.attached?
      end
      row("Pages") do |section|
        labels = FeaturedSection::PAGE_OPTIONS.invert
        section.page_keys.map { |key| labels[key] || key }.join(", ")
      end
      row :section_position
      row :display_order
      row :cta_label
      row :cta_url
      row :is_published
      row :created_at
      row :updated_at
    end
  end
end
