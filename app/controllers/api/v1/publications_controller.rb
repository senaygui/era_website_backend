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
      # Increments download_count and redirects to the file URL
      def download
        publication = Publication.published.find(params[:id])
        unless publication.file.attached?
          return render json: { error: "File not available" }, status: :not_found
        end

        # Atomic counter increment
        Publication.increment_counter(:download_count, publication.id)
        redirect_to url_for(publication.file)
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
