require "net/http"
require "rexml/document"

class YoutubeFeed
  CHANNEL_HANDLE = ENV.fetch("YOUTUBE_CHANNEL_HANDLE", "ethioroads")
  CHANNEL_ID = ENV["YOUTUBE_CHANNEL_ID"]
  REQUEST_TIMEOUT = 5

  def initialize(http_get: nil)
    @http_get = http_get || method(:get)
  end

  def latest_video
    channel_id = CHANNEL_ID.presence || resolve_channel_id
    return if channel_id.blank?

    parse_latest_video(@http_get.call(feed_url(channel_id)))
  end

  private

  def resolve_channel_id
    body = @http_get.call("https://www.youtube.com/@#{CHANNEL_HANDLE}")

    body[/<meta[^>]+itemprop=["']channelId["'][^>]+content=["'](UC[\w-]+)["']/i, 1] ||
      body[/["']channelId["']\s*:\s*["'](UC[\w-]+)["']/i, 1] ||
      body[%r{youtube\.com/channel/(UC[\w-]+)}i, 1]
  end

  def feed_url(channel_id)
    "https://www.youtube.com/feeds/videos.xml?channel_id=#{channel_id}"
  end

  def parse_latest_video(xml)
    document = REXML::Document.new(xml)
    entry = REXML::XPath.first(document, "//*[local-name()='entry']")
    return unless entry

    video_id = text_at(entry, ".//*[local-name()='videoId']")
    return if video_id.blank?

    {
      id: video_id,
      title: text_at(entry, "./*[local-name()='title']"),
      published_at: text_at(entry, "./*[local-name()='published']"),
      url: "https://www.youtube.com/watch?v=#{video_id}",
      embed_url: "https://www.youtube.com/embed/#{video_id}?autoplay=1&mute=1&playsinline=1&rel=0"
    }
  rescue REXML::ParseException => error
    Rails.logger.warn("Could not parse YouTube feed: #{error.message}")
    nil
  end

  def text_at(element, xpath)
    REXML::XPath.first(element, xpath)&.text&.strip
  end

  def get(url)
    uri = URI(url)
    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = "ERA website YouTube feed"

    Net::HTTP.start(
      uri.host,
      uri.port,
      use_ssl: uri.scheme == "https",
      open_timeout: REQUEST_TIMEOUT,
      read_timeout: REQUEST_TIMEOUT
    ) do |http|
      response = http.request(request)
      response.value
      response.body
    end
  end
end
