require "test_helper"

class YoutubeFeedTest < ActiveSupport::TestCase
  test "returns the latest video from the channel feed" do
    responses = {
      "https://www.youtube.com/@ethioroads" => '<meta itemprop="channelId" content="UC123_test">',
      "https://www.youtube.com/feeds/videos.xml?channel_id=UC123_test" => <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <feed xmlns="http://www.w3.org/2005/Atom" xmlns:yt="http://www.youtube.com/xml/schemas/2015">
          <entry>
            <yt:videoId>new-video-id</yt:videoId>
            <title>Newest ERA upload</title>
            <published>2026-09-07T08:00:00+00:00</published>
          </entry>
        </feed>
      XML
    }

    video = YoutubeFeed.new(http_get: ->(url) { responses.fetch(url) }).latest_video

    assert_equal "new-video-id", video[:id]
    assert_equal "Newest ERA upload", video[:title]
    assert_equal "2026-09-07T08:00:00+00:00", video[:published_at]
    assert_equal "https://www.youtube.com/watch?v=new-video-id", video[:url]
    assert_includes video[:embed_url], "/embed/new-video-id"
  end

  test "returns nil when the channel cannot be resolved" do
    video = YoutubeFeed.new(http_get: ->(_url) { "channel unavailable" }).latest_video

    assert_nil video
  end
end
