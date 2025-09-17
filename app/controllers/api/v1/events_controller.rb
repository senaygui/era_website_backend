module Api
  module V1
    class EventsController < ApplicationController
      def index
        @events = Event.published
                      .includes(event_image_attachment: :blob)
                      .order(start_date: :asc)
                      .page(params[:page])
                      .per(params[:per_page] || 6)

        render json: {
          events: @events.map { |event| event_json(event) },
          meta: {
            total_pages: @events.total_pages,
            current_page: @events.current_page,
            total_count: @events.total_count
          }
        }
      end

      def show
        @event = Event.published.find_by!(slug: params[:id])
        render json: event_json(@event, detailed: true)
      end

      def featured
        @events = Event.published
                      .featured
                      .includes(event_image_attachment: :blob)
                      .order(start_date: :asc)
                      .limit(3)

        render json: @events.map { |event| event_json(event) }
      end

      def upcoming
        @events = Event.published
                      .upcoming
                      .includes(event_image_attachment: :blob)
                      .order(start_date: :asc)
                      .limit(3)

        render json: @events.map { |event| event_json(event) }
      end

      private

      def event_json(event, detailed: false)
        # Safely build image URL
        image_url = nil
        if event.event_image.attached?
          begin
            image_url = Rails.application.routes.url_helpers.rails_blob_url(event.event_image, host: request.base_url)
          rescue => e
            Rails.logger.error("Failed to build image_url for event #{event.id}: #{e.class} - #{e.message}")
            image_url = nil
          end
        end

        json = {
          id: event.id,
          title: event.title,
          description: event.description,
          excerpt: event.excerpt,
          location: event.location,
          start_date: event.start_date,
          end_date: event.end_date,
          time: event.time,
          event_type: event.event_type,
          agenda: event.agenda || [],
          speakers: event.speakers || [],
          capacity: event.capacity,
          registration_required: event.registration_required,
          status: event.status,
          is_featured: event.is_featured,
          is_published: event.is_published,
          image_url: image_url,
          slug: event.slug,
          meta_title: event.meta_title,
          meta_description: event.meta_description,
          meta_keywords: event.meta_keywords,
          created_at: event.created_at,
          updated_at: event.updated_at
        }
        json
      end
    end
  end
end
