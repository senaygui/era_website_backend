module Api
  module V1
    class PublicationsController < Api::ApiController
      include ActionView::Helpers::NumberHelper

      def index
        publications = Publication.published.recent
        publications = publications.by_category(params[:category]) if params[:category].present?
        publications = publications.by_year(params[:year]) if params[:year].present?
        if params[:q].present?
          q = "%#{params[:q]}%"
          publications = publications.where("title ILIKE ? OR description ILIKE ?", q, q)
        end

        render json: publications.map { |p| serialize_publication(p) }
      end

      def show
        publication = Publication.published.find(params[:id])
        render json: serialize_publication(publication)
      end

      # GET /api/v1/publications/:id/download
      # Increments download_count and redirects to the first document URL
      def download
        publication = Publication.published.find(params[:id])
        doc = publication.documents.attached? ? publication.documents.first : nil
        return render json: { error: "File not available" }, status: :not_found unless doc

        # Atomic counter increment
        Publication.increment_counter(:download_count, publication.id)
        redirect_to url_for(doc)
      end

      private

      def serialize_publication(p)
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
