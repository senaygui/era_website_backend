class NewsSharesController < ActionController::Base
  def show
    @news = News.published.where("slug = :slug OR legacy_slugs @> ARRAY[:slug]::varchar[]", slug: params[:slug]).first!
    @title = @news.meta_title.presence || @news.title
    @description = (@news.meta_description.presence || @news.excerpt.presence || plain_content).to_s.truncate(256)
    @keywords = Array(@news.meta_keywords).join(", ")
    @image_url = url_for(@news.image) if @news.image.attached?
    @article_url = "#{frontend_origin}/news/#{ERB::Util.url_encode(@news.slug)}"
    @share_url = request.original_url

    render layout: false
  end

  private

  def plain_content
    ActionView::Base.full_sanitizer.sanitize(@news.content.to_s).squish
  end

  def frontend_origin
    configured = ENV["FRONTEND_URL"].presence || ENV["CORS_ALLOWED_ORIGINS"].to_s.split(",").first.presence
    configured || (Rails.env.production? ? "https://prod-era.era.gov.et" : "http://localhost:8080")
  end
end
