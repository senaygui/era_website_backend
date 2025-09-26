module Api
  module V1
    class RoadAssetsController < Api::ApiController
      include ActionView::Helpers::NumberHelper

      def index
        assets = RoadAsset.published.recent
        assets = assets.by_category(params[:category]) if params[:category].present?
        assets = assets.by_year(params[:year]) if params[:year].present?
        if params[:q].present?
          q = "%#{params[:q]}%"
          assets = assets.where("title ILIKE ? OR description ILIKE ?", q, q)
        end

        render json: assets.map { |p| serialize_asset(p) }
      end

      def show
        asset = RoadAsset.published.find(params[:id])
        render json: serialize_asset(asset)
      end

      # GET /api/v1/road_assets/:id/download
      def download
        asset = RoadAsset.published.find(params[:id])
        unless asset.file.attached?
          return render json: { error: "File not available" }, status: :not_found
        end

        RoadAsset.increment_counter(:download_count, asset.id)
        redirect_to url_for(asset.file)
      end

      private

      def serialize_asset(p)
        {
          id: p.id,
          title: p.title,
          category: p.category,
          year: p.year,
          publishDate: p.publish_date,
          description: p.description,
          downloadCount: p.download_count,
          isNew: p.is_new,
          authors: p.authors,
          fileType: file_type_for(p),
          fileSize: file_size_for(p),
          file_url: p.file.attached? ? url_for(p.file) : nil,
          thumbnail: p.thumbnail.attached? ? url_for(p.thumbnail) : nil
        }
      end

      def file_type_for(p)
        return nil unless p.file.attached?
        if p.file.blob.content_type.present?
          p.file.blob.content_type.split("/").last
        else
          File.extname(p.file.filename.to_s).delete(".")
        end
      end

      def file_size_for(p)
        return nil unless p.file.attached?
        number_to_human_size(p.file.blob.byte_size)
      end
    end
  end
end
