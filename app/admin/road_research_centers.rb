ActiveAdmin.register RoadResearchCenter do
  menu parent: "Resources", label: "Road Research Center"
  actions :all, except: [ :destroy, :new ]
  config.batch_actions = false

  permit_params :title, :about, :is_published, :meta_title, :meta_description, :meta_keywords,
                road_research_technologies_attributes: [ :id, :title, :category, :description, :status, :is_published, :_destroy ],
                road_research_laboratory_services_attributes: [ :id, :title, :category, :description, :status, :is_published, :_destroy ],
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
      f.input :about, as: :tiptap
      f.input :is_published
      f.input :meta_title
      f.input :meta_description, input_html: { class: "aa-plain-text" }
      f.input :meta_keywords
    end

    f.inputs "Research Technologies" do
      f.has_many :road_research_technologies, allow_destroy: true, new_record: "Add Technology" do |t|
        t.input :title
        t.input :category, as: :select, collection: [ "Soil Testing ", "Aggregate Testing", "Bitumen Testing", "Asphalt Mixture Testing", "Other" ]
        t.input :description, as: :tiptap
        t.input :status, as: :select, collection: [ "active", "archived" ], include_blank: false
        t.input :is_published
      end
    end

    f.inputs "Laboratory Services" do
      f.has_many :road_research_laboratory_services, allow_destroy: true, new_record: "Add Laboratory Service" do |s|
        s.input :title
        s.input :category
        s.input :description, as: :tiptap
        s.input :status, as: :select, collection: [ "active", "archived" ], include_blank: false
        s.input :is_published
      end
    end

    f.inputs "Gallery" do
      if f.object.gallery_images.attached?
        div do
          f.object.gallery_images.each do |img|
            div class: "gallery-image-item", style: "display: inline-flex; flex-direction: column; align-items: center; margin: 6px;" do
              if img.respond_to?(:blob) && img.blob.persisted?
                image_tag url_for(img), style: "max-width: 100px; height: auto; border-radius: 6px; border: 1px solid #eee;"
              else
                span "Pending upload", style: "display: inline-block; padding: 24px 10px; border: 1px solid #eee; border-radius: 6px;"
              end

              if img.persisted?
                # Keep the signed ID in the form, then purge it after a
                # successful update when the administrator clicks Remove.
                hidden_field_tag "road_research_center[gallery_images][]", img.signed_id
                check_box_tag "road_research_center[remove_gallery_images][]", img.signed_id, false,
                              class: "gallery-image-remove", style: "display: none;"
                link_to "Remove", "#", class: "gallery-image-remove-button", style: "margin-top: 4px; color: #c53030;",
                        onclick: "event.preventDefault(); var item = this.closest('.gallery-image-item'); item.querySelector('.gallery-image-remove').checked = true; item.style.display = 'none';"
              end
            end
          end
        end
      end
      f.input :gallery_images, as: :file, input_html: { multiple: true, accept: "image/jpeg,image/png,image/webp,image/gif" }
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

    def update
      remove_ids = Array(params.dig(:road_research_center, :remove_gallery_images)).reject(&:blank?)
      # This is a form-only control, not a RoadResearchCenter attribute.
      params[:road_research_center]&.delete(:remove_gallery_images)
      super

      # Purge only after ActiveAdmin has saved successfully. This keeps the
      # existing upload available if validation fails and the form is shown
      # again.
      if resource.errors.empty?
        remove_ids.each do |signed_id|
          attachment = resource.gallery_images.attachments.find { |item| item.signed_id == signed_id }
          attachment&.purge
        end
      end
    end
  end
end
