ActiveAdmin.register RoadResearchLaboratoryService do
  menu parent: "Resources", label: "RRC Services"
  permit_params :road_research_center_id, :title, :category, :description, :status, :is_published

  controller do
    def build_new_resource
      super.tap { |resource| resource.road_research_center ||= RoadResearchCenter.instance }
    end
  end

  index do
    selectable_column
    column :title
    column :category
    column :status
    column :is_published
    column :updated_at
    actions
  end

  filter :title
  filter :category
  filter :status
  filter :is_published

  form do |f|
    f.semantic_errors
    f.inputs "Laboratory service" do
      f.input :road_research_center_id, as: :hidden, input_html: { value: RoadResearchCenter.instance.id }
      f.input :title
      f.input :category
      f.input :description, as: :tiptap
      f.input :status, as: :select, collection: %w[active archived], include_blank: false
      f.input :is_published
    end
    f.actions
  end
end
