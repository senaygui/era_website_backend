module Api
  module V1
    class ProjectsController < BaseController
      def index
        Rails.logger.info "Processing projects index request"
        begin
          @projects = Project.published.order(created_at: :desc)
          
          # Filter by status if provided
          if params[:status].present?
            @projects = @projects.by_status(params[:status])
          end
          
          # Filter by location if provided
          if params[:location].present?
            @projects = @projects.by_location(params[:location])
          end
          
          Rails.logger.info "Found #{@projects.count} projects"
          render json: @projects.with_attached_images.with_attached_documents.map { |project| project_attributes(project, include_details: false) }
        rescue => e
          Rails.logger.error "Error in projects index: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          render json: { error: "Internal server error" }, status: :internal_server_error
        end
      end

      def completed
        Rails.logger.info "Processing completed projects request"
        begin
          @projects = Project.completed.order(end_date: :desc)
          Rails.logger.info "Found #{@projects.count} completed projects"
          render json: @projects.with_attached_images.with_attached_documents.map { |project| project_attributes(project, include_details: false) }
        rescue => e
          Rails.logger.error "Error in completed projects: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          render json: { error: "Internal server error" }, status: :internal_server_error
        end
      end

      def ongoing
        Rails.logger.info "Processing ongoing projects request"
        begin
          @projects = Project.ongoing.order(start_date: :desc)
          Rails.logger.info "Found #{@projects.count} ongoing projects"
          render json: @projects.with_attached_images.with_attached_documents.map { |project| project_attributes(project, include_details: false) }
        rescue => e
          Rails.logger.error "Error in ongoing projects: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          render json: { error: "Internal server error" }, status: :internal_server_error
        end
      end

      def show
        Rails.logger.info "Processing project show request for id: #{params[:id]}"
        begin
          @project = Project.published.with_attached_images.with_attached_documents.find(params[:id])
          Rails.logger.info "Found project: #{@project.title}"
          render json: project_attributes(@project, include_details: true)
        rescue ActiveRecord::RecordNotFound
          Rails.logger.warn "Project not found for id: #{params[:id]}"
          render json: { error: "Project not found" }, status: :not_found
        rescue => e
          Rails.logger.error "Error in project show: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          render json: { error: "Internal server error" }, status: :internal_server_error
        end
      end

      private

      def project_attributes(project, include_details: false)
        # Parse milestones and challenges from JSON strings if needed
        milestones_data = parse_json_field(project.milestones)
        challenges_data = parse_json_field(project.challenges)
        
        attributes = {
          id: project.id,
          title: project.title,
          description: project.description,
          status: project.status,
          location: project.location,
          start_date: project.start_date,
          end_date: project.end_date,
          contractor: project.contractor,
          project_manager: project.project_manager,
          images: project.images.attached? ? project.images.map { |image| 
            {
              id: image.id,
              url: url_for(image),
              thumbnail_url: url_for(image)
            }
          } : [],
          created_at: project.created_at,
          updated_at: project.updated_at
        }

        if include_details
          attributes.merge!({
            budget: project.budget,
            objectives: project.objectives,
            scope: project.scope,
            milestones: milestones_data,
            challenges: challenges_data,
            documents: project.documents.attached? ? project.documents.map { |document| 
              {
                id: document.id,
                filename: document.filename.to_s,
                content_type: document.content_type,
                url: url_for(document)
              }
            } : []
          })
        end

        attributes
      end
      
      # Helper method to parse JSON fields
      def parse_json_field(field)
        if field.is_a?(String)
          begin
            JSON.parse(field)
          rescue JSON::ParserError
            []
          end
        elsif field.nil?
          []
        else
          field
        end
      end
    end
  end
end
