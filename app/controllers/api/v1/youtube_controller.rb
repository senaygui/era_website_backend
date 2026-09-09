module Api
  module V1
    class YoutubeController < BaseController
      def latest
        video = Rails.cache.fetch("youtube/latest-video/v1", expires_in: 15.minutes, race_condition_ttl: 30.seconds, skip_nil: true) do
          YoutubeFeed.new.latest_video
        end

        if video
          render json: video
        else
          render json: { error: "Latest YouTube video is temporarily unavailable" }, status: :service_unavailable
        end
      rescue StandardError => error
        Rails.logger.warn("Could not load latest YouTube video: #{error.class} - #{error.message}")
        render json: { error: "Latest YouTube video is temporarily unavailable" }, status: :service_unavailable
      end
    end
  end
end
