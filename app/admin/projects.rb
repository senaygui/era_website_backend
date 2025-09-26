ActiveAdmin.register Project do
  permit_params :title, :description, :status, :location, :budget,
                :start_date, :end_date, :contractor, :project_manager,
                :objectives, :scope, :milestones, :challenges,
                :is_published, :meta_title, :meta_description, :meta_keywords,
                images: [], documents: []
   
                member_action :update, method: :post do
                  resource.assign_attributes(permitted_params[:project])
                  if resource.save
                    redirect_to resource_path, notice: "Project was successfully updated."
                  else
                    render :edit
                  end
                end
  index do
    selectable_column
    id_column
    column :title
    column :status
    column :location
    column :start_date
    column :end_date
    column :is_published
    column :created_at
    actions
  end

  filter :title
  filter :status
  filter :location
  filter :contractor
  filter :project_manager
  filter :created_at

  form do |f|
    f.inputs do
      f.input :title
      f.input :description, as: :text
      f.input :status, as: :select, collection: ['ongoing', 'completed', 'upcoming', 'on-hold']
      f.input :location
      f.input :budget
      f.input :start_date, as: :datepicker
      f.input :end_date, as: :datepicker
      f.input :contractor
      f.input :project_manager
      f.input :objectives, as: :text
      f.input :scope, as: :text
      f.input :milestones, as: :text, input_html: { value: f.object.milestones.to_json, hint: 'JSON array of milestone objects with title, description, date, and completed fields' }
      f.input :challenges, as: :text, input_html: { value: f.object.challenges.to_json, hint: 'JSON array of challenge objects with title and description fields' }
      f.input :images, as: :file, input_html: { multiple: true }
      f.input :documents, as: :file, input_html: { multiple: true }
      f.input :is_published
      f.input :meta_title
      f.input :meta_description
      f.input :meta_keywords
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :title
      row :description
      row :status
      row :location
      row :budget
      row :start_date
      row :end_date
      row :contractor
      row :project_manager
      row :objectives
      row :scope
      row :milestones do |project|
        milestones_data = if project.milestones.is_a?(String)
          begin
            JSON.parse(project.milestones)
          rescue JSON::ParserError
            []
          end
        else
          project.milestones
        end
        
        if milestones_data.is_a?(Array) && milestones_data.any?
          ul do
            milestones_data.each do |milestone|
              li do
                div do
                  strong { milestone['title'] || milestone[:title].to_s }
                  if milestone['description'] || milestone[:description]
                    div { milestone['description'] || milestone[:description].to_s }
                  end
                  if milestone['date'] || milestone[:date]
                    div { "Date: #{milestone['date'] || milestone[:date].to_s}" }
                  end
                  completed = milestone['completed'] || milestone[:completed]
                  div { "Status: #{completed ? 'Completed' : 'In Progress'}" }
                end
              end
            end
          end
        else
          span { "No milestones" }
        end
      end
      
      row :challenges do |project|
        challenges_data = if project.challenges.is_a?(String)
          begin
            JSON.parse(project.challenges)
          rescue JSON::ParserError
            []
          end
        else
          project.challenges
        end
        
        if challenges_data.is_a?(Array) && challenges_data.any?
          ul do
            challenges_data.each do |challenge|
              li do
                div do
                  strong { challenge['title'] || challenge[:title].to_s }
                  if challenge['description'] || challenge[:description]
                    div { challenge['description'] || challenge[:description].to_s }
                  end
                end
              end
            end
          end
        else
          span { "No challenges" }
        end
      end
      row :images do |project|
        if project.images.attached?
          ul do
            project.images.each do |img|
              li do
                span image_tag(url_for(img), style: 'max-width: 200px; max-height: 200px')
                span link_to 'View', url_for(img), target: '_blank'
              end
            end
          end
        end
      end
      row :documents do |project|
        if project.documents.attached?
          ul do
            project.documents.each do |doc|
              li do
                span doc.filename.to_s
                span link_to 'Download', url_for(doc), target: '_blank'
              end
            end
          end
        end
      end
      row :is_published
      row :meta_title
      row :meta_description
      row :meta_keywords
      row :created_at
      row :updated_at
    end
  end
end
