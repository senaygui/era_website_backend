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
        doc = asset.documents.attached? ? asset.documents.first : nil
        return render json: { error: "File not available" }, status: :not_found unless doc

        RoadAsset.increment_counter(:download_count, asset.id)
        redirect_to url_for(doc)
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
          documents: p.documents.map { |d| serialize_blob(d) },
          thumbnail: p.thumbnail.attached? ? url_for(p.thumbnail) : nil
        }
      end

      def serialize_blob(att)
        b = att.blob
        {
          id: att.id,
          filename: b.filename.to_s,
          content_type: b.content_type,
          byte_size: b.byte_size,
          url: url_for(att)
        }
      end
    end
  end
end
