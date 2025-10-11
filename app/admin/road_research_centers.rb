ActiveAdmin.register RoadResearchCenter do
  menu parent: "Resources", label: "Road Research Center"
  actions :all, except: [:destroy, :new]
  config.batch_actions = false

  permit_params :title, :about, :is_published, :meta_title, :meta_description, :meta_keywords,
                road_research_technologies_attributes: [:id, :title, :category, :description, :status, :is_published, :_destroy],
                road_research_laboratory_services_attributes: [:id, :title, :category, :description, :status, :is_published, :_destroy],
                gallery_images: []

  filter :title
  filter :is_published

  index do
    columns do
      column do
        panel "Road Research Center" do
          div do
            link_to "Edit Road Research Center", edit_resource_path(RoadResearchCenter.instance)
          end
        end
      end
    end
  end

  show do
    attributes_table do
      row :title
      row :about do |rec|
        simple_format(rec.about)
      end
      row :is_published
      row :meta_title
      row :meta_description
      row :meta_keywords
    end

    panel "Technologies" do
      table_for resource.road_research_technologies do
        column :title
        column :category
        column :status
        column :is_published
      end
    end

    panel "Laboratory Services" do
      table_for resource.road_research_laboratory_services do
        column :title
        column :category
        column :status
        column :is_published
      end
    end

    panel "Gallery" do
      if resource.gallery_images.attached?
        div do
          resource.gallery_images.each do |img|
            span do
              image_tag url_for(img), style: "max-width: 120px; height: auto; margin: 6px; border-radius: 6px; border: 1px solid #eee;"
            end
          end
        end
      else
        span "No gallery images uploaded."
      end
    end

    active_admin_comments
  end

  form do |f|
    f.semantic_errors

    f.inputs "Center Details" do
      f.input :title
      f.input :about, as: :text, input_html: { rows: 6 }
      f.input :is_published
      f.input :meta_title
      f.input :meta_description
      f.input :meta_keywords
    end

    f.inputs "Research Technologies" do
      f.has_many :road_research_technologies, allow_destroy: true, new_record: "Add Technology" do |t|
        t.input :title
        t.input :category, as: :select, collection: ["Soil Testing ", "Aggregate Testing", "Bitumen Testing", "Asphalt Mixture Testing", "Other"]
        t.input :description
        t.input :status, as: :select, collection: ["active", "archived"], include_blank: false
        t.input :is_published
      end
    end

    f.inputs "Laboratory Services" do
      f.has_many :road_research_laboratory_services, allow_destroy: true, new_record: "Add Laboratory Service" do |s|
        s.input :title
        s.input :category
        s.input :description
        s.input :status, as: :select, collection: ["active", "archived"], include_blank: false
        s.input :is_published
      end
    end

    f.inputs "Gallery" do
      if f.object.gallery_images.attached?
        div do
          f.object.gallery_images.each do |img|
            span do
              image_tag url_for(img), style: "max-width: 100px; height: auto; margin: 6px; border-radius: 6px; border: 1px solid #eee;"
            end
          end
        end
      end
      f.input :gallery_images, as: :file, input_html: { multiple: true, accept: 'image/*' }
      li "Upload multiple images to the center's gallery."
    end

    f.actions
  end

  controller do
    def index
      redirect_to edit_resource_path(RoadResearchCenter.instance)
    end

    def new
      redirect_to edit_resource_path(RoadResearchCenter.instance)
    end

    def create
      redirect_to edit_resource_path(RoadResearchCenter.instance)
    end

    def edit
      @road_research_center = RoadResearchCenter.instance
      super
    end

    def show
      @road_research_center = RoadResearchCenter.instance
      super
    end
  end
end
