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
        unless report.file.attached?
          return render json: { error: "File not available" }, status: :not_found
        end

        PerformanceReport.increment_counter(:download_count, report.id)
        redirect_to url_for(report.file)
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
