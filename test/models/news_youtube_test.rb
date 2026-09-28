require "test_helper"

class NewsYoutubeTest < ActiveSupport::TestCase
  test "extracts ids from supported YouTube URLs" do
    urls = [
      "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      "https://youtu.be/dQw4w9WgXcQ?t=15",
      "https://www.youtube.com/shorts/dQw4w9WgXcQ",
      "https://www.youtube.com/embed/dQw4w9WgXcQ"
    ]

    urls.each do |url|
      news = News.new(youtube_url: url)
      assert_equal "dQw4w9WgXcQ", news.youtube_video_id
      assert_includes news.youtube_embed_url, "youtube-nocookie.com/embed/dQw4w9WgXcQ"
    end
  end

  test "rejects non-YouTube video URLs" do
    news = News.new(youtube_url: "https://example.com/watch?v=dQw4w9WgXcQ")

    news.validate

    assert news.errors[:youtube_url].present?
  end
end
