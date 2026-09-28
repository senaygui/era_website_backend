ActiveAdmin.register RoadResearchGalleryImage do
  menu parent: "Resources", label: "RRC Gallery"
  permit_params :road_research_center_id, :title, :caption, :position, :is_published, :image
  config.sort_order = "position_asc"

  controller do
    def build_new_resource
      super.tap { |resource| resource.road_research_center ||= RoadResearchCenter.instance }
    end
  end

  index do
    selectable_column
    column :image do |item|
      image_tag(url_for(item.image.variant(resize_to_fill: [ 140, 90 ]))) if item.image.attached?
    end
    column :title
    column :position
    column :is_published
    column :updated_at
    actions
  end

  filter :title
  filter :is_published

  form do |f|
    f.semantic_errors
    f.inputs "Gallery image" do
      f.input :road_research_center_id, as: :hidden, input_html: { value: RoadResearchCenter.instance.id }
      f.input :title
      f.input :caption, as: :text, input_html: { rows: 3, class: "aa-plain-text" }
      f.input :image, as: :file,
              hint: f.object.image.attached? ? image_tag(url_for(f.object.image.variant(resize_to_limit: [ 400, 240 ]))) : "Required"
      f.input :position, hint: "Lower numbers appear first in the slider."
      f.input :is_published
    end
    f.actions
  end

  show do
    attributes_table do
      row :title
      row :caption
      row(:image) { |item| image_tag(item.image, style: "max-width: 720px; height: auto;") if item.image.attached? }
      row :position
      row :is_published
      row :created_at
      row :updated_at
    end
  end
end
