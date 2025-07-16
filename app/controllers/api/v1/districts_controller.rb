module Api
  module V1
    class DistrictsController < ApplicationController
      before_action :set_district, only: [ :show, :update, :destroy ]

      def index
        @districts = District.where(is_published: true)
                           .order(created_at: :desc)
                           .page(params[:page])
                           .per(params[:per_page] || 10)

        render json: {
          districts: @districts.map { |district| district_with_urls(district) },
          meta: {
            current_page: @districts.current_page,
            total_pages: @districts.total_pages,
            total_count: @districts.total_count
          }
        }
      end

      def show
        if @district
          render json: district_with_urls(@district)
        else
          render json: { error: "District not found" }, status: :not_found
        end
      end

      def create
        @district = District.new(district_params)
        if @district.save
          render json: district_with_urls(@district), status: :created
        else
          render json: { errors: @district.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @district.update(district_params)
          render json: district_with_urls(@district)
        else
          render json: { errors: @district.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @district.destroy
        head :no_content
      rescue ActiveRecord::RecordNotDestroyed
        render json: { error: "Failed to delete district" }, status: :unprocessable_entity
      end

      private

      def set_district
        @district = District.find_by(id: params[:id])
      rescue ActiveRecord::RecordNotFound
        @district = nil
      end

      def district_params
        params.require(:district).permit(
          :name,
          :address,
          :map_embed,
          :district_overview,
          :detail_description,
          :is_published,
          :meta_title,
          :meta_description,
          :published_by,
          :updated_by,
          :main_image,
          phone_numbers: [],
          emails: [],
          social_media_links: [],
          meta_keywords: [],
          gallery_images: []
        )
      end

      def district_with_urls(district)
        district.as_json.merge(
          main_image_url: district.main_image.attached? ? rails_blob_url(district.main_image) : nil,
          gallery_images_urls: district.gallery_images.attached? ? district.gallery_images.map { |img| rails_blob_url(img) } : []
        )
      end
    end
  end
end
