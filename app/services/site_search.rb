class SiteSearch
  PER_PAGE = 20
  MAX_QUERY_LENGTH = 200
  PAGES = [
    ["About Us", "/about", "Mission vision history leadership Ethiopian Roads Administration ስለ እኛ ተልእኮ ራዕይ"],
    ["Projects", "/projects", "Road construction bridges infrastructure ፕሮጀክቶች መንገድ ግንባታ"],
    ["News", "/news", "Latest news announcements updates ዜናዎች"],
    ["Bids & Tenders", "/bids", "Procurement bidding opportunities ጨረታዎች"],
    ["Events", "/events", "Workshops calendar conferences ዝግጅቶች"],
    ["Publications", "/publications", "Reports manuals guidelines documents ህትመቶች መመሪያዎች"],
    ["Road Assets", "/publications/road-assets", "Road assets resources የመንገድ ንብረቶች"],
    ["Performance Rate", "/publications/performance", "Performance reports rates የአፈጻጸም መጠን"],
    ["Road Research Center", "/publications/road-research-center", "Research technology laboratory የመንገድ ምርምር ማዕከል"],
    ["Vacancies", "/vacancies", "Jobs careers employment applications ሥራ እድሎች"],
    ["Districts", "/districts", "Regional offices locations ዲስትሪክቶች"],
    ["Contact Us", "/contact", "Address phone email location አድራሻ ስልክ"],
    ["Frequently Asked Questions", "/faq", "FAQ help answers ተደጋጋሚ ጥያቄዎች"]
  ].freeze

  def initialize(query, page: 1)
    @query = query.to_s.strip.first(MAX_QUERY_LENGTH)
    @terms = @query.downcase.split.first(10)
    @page = page.to_i.clamp(1, 1000)
  end

  def call
    return { query: @query, results: [], total: 0, page: 1, per_page: PER_PAGE } if @terms.empty?

    pages = PAGES.filter_map do |title, url, description|
      next unless @terms.all? { |term| "#{title} #{description}".downcase.include?(term) }
      { id: url, title: title, url: url, category: "Pages", excerpt: description }
    end
    sources = [
      [News.published, %w[title excerpt content], "News", "/news", :slug],
      [Project.published, %w[title description location], "Projects", "/projects", :id],
      [Bid.published, %w[title description bid_number category], "Bids", "/bids", nil],
      [Publication.published, %w[title description category], "Publications", "/publications", nil],
      [Event.published, %w[title description location event_type], "Events", "/events", nil],
      [Vacancy.active, %w[title description department location], "Vacancies", "/vacancies", nil],
      [District.where(is_published: true), %w[name district_overview detail_description], "Districts", "/districts", :id],
      [RoadAsset.published, %w[title description category], "Road Assets", "/publications/road-assets", nil],
      [PerformanceReport.published, %w[title description category], "Performance Rate", "/publications/performance", nil]
    ].map do |scope, fields, category, path, identifier|
      @terms.each do |term|
        pattern = "%#{ActiveRecord::Base.sanitize_sql_like(term)}%"
        scope = scope.where(fields.map { |field| "#{field} ILIKE :pattern" }.join(" OR "), pattern: pattern)
      end
      [scope, fields, category, path, identifier, scope.count]
    end
    total = pages.length + sources.sum { |source| source.last }
    page = [@page, [(total.to_f / PER_PAGE).ceil, 1].max].min
    offset = (page - 1) * PER_PAGE
    results = pages.drop(offset).first(PER_PAGE)
    offset = [offset - pages.length, 0].max
    sources.each do |scope, fields, category, path, identifier, count|
      break if results.length == PER_PAGE
      if offset >= count
        offset -= count
        next
      end
      records = scope.reorder(fields.first => :asc, id: :asc).offset(offset).limit(PER_PAGE - results.length)
      records.each do |record|
        title = record.public_send(fields.first)
        description = fields.drop(1).map { |field| record.public_send(field) }.compact.join(" ")
        url = identifier ? "#{path}/#{ERB::Util.url_encode(record.public_send(identifier).to_s)}" : "#{path}?search=#{ERB::Util.url_encode(title)}"
        results << { id: "#{category}:#{record.id}", title: title, category: category, url: url,
          excerpt: ActionController::Base.helpers.strip_tags(description).squish.truncate(220) }
      end
      offset = 0
    end
    { query: @query, results: results, total: total, page: page, per_page: PER_PAGE }
  end
end
