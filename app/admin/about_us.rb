ActiveAdmin.register AboutUs do
  # Since there should only be one About Us page, we'll remove the "New" button
  actions :all, except: [ :destroy, :new ]

  # Permit parameters
  permit_params :title, :subtitle, :description, :mission, :vision, :values, :values_title,
                :history, :team_description, :achievements, :achievements_description,
                :milestones, :milestones_description, :partners,
                :is_published, :meta_title, :meta_description, :meta_keywords,
                :hero_image, :mission_image, :vision_image, :history_image, :org_structure_image,
                team_images: [],
                team_members_attributes: [ :id, :name, :position, :job_title, :description, :image, :_destroy ]

  member_action :update, method: :post do
    resource.assign_attributes(permitted_params[:about_us])
    if resource.save
      redirect_to resource_path, notice: "About Us was successfully updated."
    else
      render :edit
    end
  end

  # Index page configuration
  index do
    column :title
    column :subtitle
    column :updated_at
    column :is_published
    actions
  end
  
  filter :title
  filter :is_published
  filter :updated_at
  # Form configuration
  form do |f|
    f.semantic_errors

    f.inputs "Basic Information" do
      f.input :title
      f.input :subtitle
      f.input :description, as: :text, input_html: { rows: 5 }
      f.input :hero_image, as: :file, hint: f.object.persisted? && f.object.hero_image.attached? ? image_tag(f.object.hero_image, size: "200x150", class: "img-corner") : "No image uploaded"
    end

    f.inputs "Mission & Vision" do
      f.input :mission, as: :text, input_html: { rows: 4 }
      f.input :mission_image, as: :file, hint: f.object.persisted? && f.object.mission_image.attached? ? image_tag(f.object.mission_image, size: "200x150", class: "img-corner") : "No image uploaded"
      f.input :vision, as: :text, input_html: { rows: 4 }
      f.input :vision_image, as: :file, hint: f.object.persisted? && f.object.vision_image.attached? ? image_tag(f.object.vision_image, size: "200x150", class: "img-corner") : "No image uploaded"
    end

    f.inputs "Core Values" do
      f.input :values_title, label: "Core Values Title"
      f.input :values, as: :text, input_html: {
        rows: 5,
        value: f.object.values.is_a?(Array) ? f.object.values.map { |v| "#{v['title']}|#{v['description']}" }.join("\n") : (f.object.values.is_a?(String) ? f.object.values : "")
      }, hint: "Format: Value Title|Description (one per line)"
    end

    f.inputs "History & Team" do
      f.input :history, as: :text, input_html: { rows: 4 }
      f.input :history_image, as: :file, hint: f.object.persisted? && f.object.history_image.attached? ? image_tag(f.object.history_image, size: "200x150", class: "img-corner") : "No image uploaded"
      f.input :org_structure_image, as: :file, hint: f.object.persisted? && f.object.org_structure_image.attached? ? image_tag(f.object.org_structure_image, size: "200x150", class: "img-corner") : "No image uploaded"
      f.input :team_description, as: :text, input_html: { rows: 4 }

      f.has_many :team_members, allow_destroy: true, new_record: true, heading: "Team Members" do |tm|
        tm.input :name
        tm.input :job_title
        tm.input :description, as: :text, input_html: { rows: 3 }
        tm.input :image, as: :file, hint: (tm.object.persisted? && tm.object.image.attached?) ? image_tag(tm.object.image, size: "100x100", class: "img-corner") : "No image uploaded"
      end
      f.input :team_images, as: :file, input_html: { multiple: true }

      if f.object.persisted? && f.object.team_images.attached?
        div class: "panel" do
          h3 "Team Images"
          div class: "panel_contents" do
            div class: "attributes_table" do
              table do
                f.object.team_images.each do |img|
                  tr do
                    td do
                      image_tag(img, size: "150x150", class: "img-corner")
                    end
                  end
                end
              end
            end
          end
        end
      end
    end

    f.inputs "Achievements, Milestones & Partners" do
      f.input :achievements_description, label: "Major Achievements Description", as: :text, input_html: { rows: 3, placeholder: "Provide an overview of the organization's major achievements" }
      f.input :achievements, as: :text, input_html: {
        rows: 5,
        value: f.object.achievements.is_a?(Array) ? f.object.achievements.map { |a| "#{a['stats']}|#{a['title']}|#{a['description']}" }.join("\n") : ""
      }, hint: "Format: Stats|Title|Description (one per line)"

      f.input :milestones_description, label: "Milestones Description", as: :text, input_html: { rows: 3, placeholder: "Provide an overview of the organization's journey and key milestones" }
      f.input :milestones, as: :text, input_html: {
        rows: 5,
        value: f.object.milestones.is_a?(Array) ? f.object.milestones.map { |m| "#{m['year']}|#{m['title']}|#{m['description']}" }.join("\n") : ""
      }, hint: "Format: Year|Title|Description (one per line)"

      f.input :partners, as: :text, input_html: {
        rows: 5,
        value: f.object.partners.is_a?(Array) ? f.object.partners.map { |p| "#{p['name']}|#{p['logo_url']}" }.join("\n") : ""
      }, hint: "Format: Name|Logo URL (one per line)"
    end

    f.inputs "SEO Information" do
      f.input :meta_title
      f.input :meta_description, as: :text, input_html: { rows: 3 }
      f.input :meta_keywords
      f.input :is_published
    end

    f.actions
  end

  # Show page configuration
  show do
    attributes_table do
      panel "Basic Information" do
        attributes_table_for resource do
          row :title
          row :subtitle
          row :description
          row :hero_image do |about|
            image_tag(about.hero_image, size: "300x200", class: "img-corner") if about.hero_image.attached?
          end
        end
      end
      
      panel "Mission & Vision" do
        attributes_table_for resource do
          row :mission
          row :mission_image do |about|
            image_tag(about.mission_image, size: "300x200", class: "img-corner") if about.mission_image.attached?
          end

          row :vision
          row :vision_image do |about|
            image_tag(about.vision_image, size: "300x200", class: "img-corner") if about.vision_image.attached?
          end
        end
      end
      
      panel "Core Values" do
        attributes_table_for resource do
          row :values_title
          row :values do |about|
            if about.values.is_a?(Array)
              table do
                thead do
                  tr do
                    th "Title"
                    th "Description"
                  end
                end
                tbody do
                  about.values.each do |value|
                    tr do
                      td { value["title"] }
                      td { value["description"] }
                    end
                  end
                end
              end
            else
              para about.values
            end
          end
        end
      end

      panel "History & Team" do
        attributes_table_for resource do
          row :history
          row :history_image do |about|
            image_tag(about.history_image, size: "300x200", class: "img-corner") if about.history_image.attached?
          end

          row :org_structure_image do |about|
            image_tag(about.org_structure_image, size: "300x200", class: "img-corner") if about.org_structure_image.attached?
          end

          row :team_description
          row :team_members do |about|
            table do
              thead do
                tr do
                  th "Name"
                  th "Job Title"
                  th "Photo"
                  th "Description"
                end
              end
              tbody do
                about.team_members.each do |member|
                  tr do
                    td { member.name }
                    td { member.job_title }
                    td {
                      if member.image.attached?
                        image_tag(member.image, size: "80x80", class: "img-corner")
                      else
                        span { "No image" }
                      end
                    }
                    td { member.description }
                  end
                end
              end
            end
          end
          row :team_images do |about|
            div do
              about.team_images.each do |img|
                span do
                  image_tag(img, size: "150x150", class: "img-corner")
                end
              end
            end if about.team_images.attached?
          end
        end
      end

      panel "Achievements & Milestones" do
        attributes_table_for resource do
          row :achievements_description, label: "Major Achievements Description"
          row :achievements do |about|
            table do
              thead do
                tr do
                  th "Stats"
                  th "Title"
                  th "Description"
                end
              end
              tbody do
                about.achievements_list.each do |achievement|
                  tr do
                    td { achievement["stats"] }
                    td { achievement["title"] }
                    td { achievement["description"] }
                  end
                end
              end
            end
          end

          row :milestones_description
          row :milestones do |about|
            table do
              thead do
                tr do
                  th "Year"
                  th "Title"
                  th "Description"
                end
              end
              tbody do
                about.milestones_list.each do |milestone|
                  tr do
                    td { milestone["year"] }
                    td { milestone["title"] }
                    td { milestone["description"] }
                  end
                end
              end
            end
          end
        end
      end
      
      panel "Partners" do
        attributes_table_for resource do
          row :partners do |about|
            ul do
              about.partners_list.each do |partner|
                li do
                  span { partner["name"] }
                end
              end
            end
          end
        end
      end

      panel "SEO & Publishing" do
        attributes_table_for resource do
          row :meta_title
          row :meta_description
          row :meta_keywords
          row :is_published
        end
      end
      row :created_at
      row :updated_at
    end
  end

  # Controller customization
  controller do
    def scoped_collection
      super
    end

    def create
      super
    end

    def update
      about_params = permitted_params[:about_us].to_h

      # Handle achievements as JSON
      if params[:about_us][:achievements].present?
        achievements = params[:about_us][:achievements].split("\n").map do |line|
          parts = line.strip.split("|") 
          next if parts.size < 3
          { 
            "stats" => parts[0].strip,
            "title" => parts[1].strip, 
            "description" => parts[2].strip 
          }
        end.compact
        about_params[:achievements] = achievements
      end

      # Handle milestones as JSON
      if params[:about_us][:milestones].present?
        milestones = params[:about_us][:milestones].split("\n").map do |line|
          parts = line.strip.split("|") 
          next if parts.size < 3
          { 
            "year" => parts[0].strip, 
            "title" => parts[1].strip,
            "description" => parts[2].strip 
          }
        end.compact
        about_params[:milestones] = milestones
      end

      # Handle values as JSON
      if params[:about_us][:values].present? && !params[:about_us][:values].include?("<")
        values = params[:about_us][:values].split("\n").map do |line|
          parts = line.strip.split("|") 
          next if parts.size < 2
          { "title" => parts[0].strip, "description" => parts[1].strip }
        end.compact
        about_params[:values] = values unless values.empty?
      end

      # Handle partners as JSON
      if params[:about_us][:partners].present?
        partners = params[:about_us][:partners].split("\n").map do |line|
          parts = line.strip.split("|") 
          next if parts.size < 2
          { "name" => parts[0].strip, "logo_url" => parts[1].strip }
        end.compact
        about_params[:partners] = partners
      end

      if resource.update(about_params)
        redirect_to admin_about_us_path(resource), notice: "About Us was successfully updated."
      else
        render :edit
      end
    end
  end

  # Remove the default New About Us link
  config.clear_action_items!

  action_item :edit, only: :show do
    link_to "Edit About Us", edit_admin_about_us_path(resource)
  end

  # Custom action to toggle published status
  action_item :toggle_published, only: :show do
    link_to resource.is_published ? "Unpublish" : "Publish",
            toggle_published_admin_about_us_path(resource),
            method: :put
  end

  member_action :toggle_published, method: :put do
    resource.update(is_published: !resource.is_published)
    redirect_to admin_about_us_path(resource), notice: "About Us #{resource.is_published ? 'published' : 'unpublished'} successfully"
  end
end
