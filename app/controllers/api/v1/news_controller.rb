module Api
  module V1
    class NewsController < BaseController
      def index
        Rails.logger.info "Processing news index request"
        begin
          @news = News.where(is_published: true)
                     .order(published_date: :desc)
                     .includes(image_attachment: :blob)
          Rails.logger.info "Found #{@news.count} news articles"
          render json: @news.map { |news| news_attributes(news) }
        rescue => e
          Rails.logger.error "Error in news index: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          render json: { error: "Internal server error" }, status: :internal_server_error
        end
      end

      def show
        Rails.logger.info "Processing news show request for slug: #{params[:id]}"
        begin
          @news = News.find_by!(slug: params[:id])
          @news.increment_view_count
          Rails.logger.info "Found news article: #{@news.title}"
          render json: news_attributes(@news)
        rescue ActiveRecord::RecordNotFound
          Rails.logger.warn "News not found for slug: #{params[:id]}"
          render json: { error: "News not found" }, status: :not_found
        rescue => e
          Rails.logger.error "Error in news show: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          render json: { error: "Internal server error" }, status: :internal_server_error
        end
      end

      private

      def news_attributes(news)
        {
          id: news.id,
          title: news.title,
          content: news.content,
          excerpt: news.excerpt,
          published_date: news.published_date,
          category: news.category,
          tags: news.tags,
          is_featured: news.is_featured,
          view_count: news.view_count,
          author: news.author,
          image_url: news.image.attached? ? url_for(news.image) : nil,
          thumbnail_url: news.image.attached? ? url_for(news.image.variant(resize_to_limit: [ 300, 300 ])) : nil,
          created_at: news.created_at,
          updated_at: news.updated_at
        }
      end
    end
  end
end
