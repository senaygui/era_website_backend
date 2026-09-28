ActiveAdmin.register RoadResearchCenter do
  menu parent: "Resources", label: "RRC Landing Page"
  actions :all, except: [ :destroy, :new ]
  config.batch_actions = false

  permit_params :title, :hero_headline, :hero_subheadline, :hero_image,
                :about, :vision, :mission, :objectives,
                :organizational_structure, :organizational_structure_image,
                :contact_address, :contact_phone, :contact_email,
                :contact_hours, :contact_map_url, :is_published,
                :meta_title, :meta_description, :meta_keywords

  filter :title
  filter :is_published

  index do
    column :title
    column :hero_headline
    column :is_published
    column :updated_at
    actions defaults: false do |center|
      item "Edit landing page", edit_admin_road_research_center_path(center)
    end
  end

  form do |f|
    f.semantic_errors

    f.inputs "Hero section" do
      f.input :title, hint: "Internal/admin title and fallback headline."
      f.input :hero_headline
      f.input :hero_subheadline, as: :text, input_html: { rows: 3, class: "aa-plain-text" }
      f.input :hero_image, as: :file, label: "Gateway background image",
              hint: f.object.hero_image.attached? ? image_tag(url_for(f.object.hero_image.variant(resize_to_limit: [ 480, 240 ]))) : "Use a wide, high-resolution gateway image."
    end

    f.inputs "Institutional content" do
      f.input :about, as: :tiptap, label: "About RRC (History)"
      f.input :vision, as: :tiptap
      f.input :mission, as: :tiptap
      f.input :objectives, as: :tiptap, label: "Objectives of RRC"
      f.input :organizational_structure, as: :tiptap, label: "RRC Organizational Structure"
      f.input :organizational_structure_image, as: :file,
              hint: f.object.organizational_structure_image.attached? ? image_tag(url_for(f.object.organizational_structure_image.variant(resize_to_limit: [ 480, 320 ]))) : "Optional organization chart image."
    end

    f.inputs "Contact information" do
      f.input :contact_address
      f.input :contact_phone
      f.input :contact_email
      f.input :contact_hours
      f.input :contact_map_url, hint: "Optional Google Maps or location URL."
    end

    f.inputs "Publishing and SEO" do
      f.input :is_published
      f.input :meta_title
      f.input :meta_description, as: :text, input_html: { rows: 3, class: "aa-plain-text" }
      f.input :meta_keywords
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
