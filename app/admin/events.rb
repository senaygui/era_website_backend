ActiveAdmin.register Event do
   menu parent: "Events & News", priority: 1
  # Permit parameters
  permit_params :event_image, :title, :description, :excerpt, :location,
                :start_date, :end_date, :time, :event_type, :agenda, :speakers,
                :capacity, :registration_required, :status, :is_road_research_center_event,
                :is_featured, :is_published, :meta_title, :meta_description,
                :meta_keywords

  # Configure event_type as a string column
  config.sort_order = "created_at_desc"
  config.filters = true
  config.per_page = 20
  member_action :update, method: :post do
    resource.assign_attributes(permitted_params[:event])
    if resource.save
      redirect_to resource_path, notice: "Event was successfully updated."
    else
      render :edit
    end
  end

  # Index page configuration
  index do
    selectable_column

    column :title
    column :event_type, as: :string
    column :location
    column :is_road_research_center_event
    column :start_date
    column :end_date
    column :status
    column :created_at

    actions
  end

  # Filters
  filter :title
  filter :event_type
  filter :location
  filter :is_road_research_center_event
  filter :start_date
  filter :end_date
  filter :status
  filter :capacity
  filter :registration_required
  filter :is_featured
  filter :is_published
  filter :created_at

  # Form configuration
  form do |f|
    f.semantic_errors

    f.inputs "Basic Information" do
      f.input :title
      f.input :excerpt
      f.input :description, as: :text, input_html: { rows: 5 }
      f.input :event_image, as: :file
      f.input :location
      f.input :event_type, as: :select, collection: [ "Conference", "Workshop", "Seminar", "Training", "Public Consultation", "Launch Event" ]
    end

    f.inputs "Date and Time" do
      f.input :start_date, as: :datetime_picker
      f.input :end_date, as: :datetime_picker
      f.input :time, hint: "Format: 9:00 AM - 5:00 PM"
    end

    f.inputs "Event Details" do
      f.input :status, as: :select, collection: [ "upcoming", "ongoing", "completed", "cancelled" ]
      f.input :capacity
      f.input :registration_required
      f.input :agenda, as: :text, input_html: {
        rows: 5,
        value: f.object.agenda&.join("\n")
      }, hint: "Add each agenda item on a new line"
      f.input :speakers, as: :text, input_html: {
        rows: 5,
        value: f.object.speakers&.join("\n")
      }, hint: "Add each speaker on a new line"
    end

    f.inputs "Settings" do
      f.input :is_featured
      f.input :is_published
      f.input :is_road_research_center_event, label: "Road Research Center related"
    end

    f.inputs "SEO Information" do
      f.input :meta_title
      f.input :meta_description
      f.input :meta_keywords
    end

    f.actions
  end

  # Show page configuration
  show do
    attributes_table do
      row :id
      row :title
      row :excerpt
      row :description
      row :event_image do |event|
        if event.event_image.attached?
          image_tag(event.event_image, size: "150x150", class: "img-corner")
        else
          "No image uploaded"
        end
      end
      row :location
      row :start_date
      row :end_date
      row :time
      row :event_type
      row :is_road_research_center_event
      row :status
      row :capacity
      row :registration_required
      row :agenda do |event|
        event.agenda&.join("<br>")&.html_safe
      end
      row :speakers do |event|
        event.speakers&.join("<br>")&.html_safe
      end
      row :is_featured
      row :is_published
      row :meta_title
      row :meta_description
      row :meta_keywords
      row :created_at
      row :updated_at
    end
  end

  # Custom actions
  action_item :toggle_featured, only: :show do
    link_to resource.is_featured ? "Unfeature" : "Feature",
            toggle_featured_admin_event_path(resource),
            method: :put
  end

  action_item :toggle_published, only: :show do
    link_to resource.is_published ? "Unpublish" : "Publish",
            toggle_published_admin_event_path(resource),
            method: :put
  end

  member_action :toggle_featured, method: :put do
    resource.update(is_featured: !resource.is_featured)
    redirect_to admin_event_path(resource), notice: "Event #{resource.is_featured ? 'featured' : 'unfeatured'} successfully"
  end

  member_action :toggle_published, method: :put do
    resource.update(is_published: !resource.is_published)
    redirect_to admin_event_path(resource), notice: "Event #{resource.is_published ? 'published' : 'unpublished'} successfully"
  end

  # Batch actions
  batch_action :toggle_featured do |ids|
    Event.where(id: ids).update_all(is_featured: true)
    redirect_to collection_path, notice: "Selected events have been featured"
  end

  batch_action :toggle_published do |ids|
    Event.where(id: ids).update_all(is_published: true)
    redirect_to collection_path, notice: "Selected events have been published"
  end

  # Controller customization
  controller do
    def scoped_collection
      super
    end

    def create
      event_params = permitted_params[:event].to_h

      # Handle agenda and speakers as arrays
      if params[:event][:agenda].present?
        event_params[:agenda] = params[:event][:agenda].split("\n").map(&:strip).reject(&:empty?)
      end

      if params[:event][:speakers].present?
        event_params[:speakers] = params[:event][:speakers].split("\n").map(&:strip).reject(&:empty?)
      end

      @event = Event.new(event_params)

      if @event.save
        redirect_to admin_event_path(@event), notice: "Event was successfully created."
      else
        render :new
      end
    end

    def update
      @event = Event.find(params[:id])
      event_params = permitted_params[:event].to_h

      # Handle agenda and speakers as arrays
      if params[:event][:agenda].present?
        event_params[:agenda] = params[:event][:agenda].split("\n").map(&:strip).reject(&:empty?)
      end

      if params[:event][:speakers].present?
        event_params[:speakers] = params[:event][:speakers].split("\n").map(&:strip).reject(&:empty?)
      end

      if @event.update(event_params)
        redirect_to admin_event_path(@event), notice: "Event was successfully updated."
      else
        render :edit
      end
    end
  end
end
