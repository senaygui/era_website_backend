module Api
  module V1
    class PerformanceReportsController < Api::ApiController
      include ActionView::Helpers::NumberHelper

      def index
        reports = PerformanceReport.published.recent
        reports = reports.by_category(params[:category]) if params[:category].present?
        reports = reports.by_year(params[:year]) if params[:year].present?
        if params[:q].present?
          q = "%#{params[:q]}%"
          reports = reports.where("title ILIKE ? OR description ILIKE ?", q, q)
        end

        render json: reports.map { |p| serialize_report(p) }
      end

      def show
        report = PerformanceReport.published.find(params[:id])
        render json: serialize_report(report)
      end

      # GET /api/v1/performance_reports/:id/download
      def download
        report = PerformanceReport.published.find(params[:id])
        doc = report.documents.attached? ? report.documents.first : nil
        return render json: { error: "File not available" }, status: :not_found unless doc

        PerformanceReport.increment_counter(:download_count, report.id)
        redirect_to url_for(doc)
      end

      private

      def serialize_report(p)
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
