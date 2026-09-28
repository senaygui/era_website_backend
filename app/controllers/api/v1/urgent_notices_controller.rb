module Api
  module V1
    class UrgentNoticesController < BaseController
      def index
        notices = UrgentNotice.published.not_expired.newest_first.includes(file_attachment: :blob).limit(10)
        render json: notices.map { |notice| notice_json(notice) }
      end

      private

      def notice_json(notice)
        {
          id: notice.id,
          notice_title: notice.notice_title,
          notice_short_description: notice.notice_short_description,
          destination_url: notice.file.attached? ? url_for(notice.file) : notice.link_url,
          destination_type: notice.file.attached? ? "file" : "link",
          filename: notice.file.attached? ? notice.file.filename.to_s : nil,
          expires_at: notice.expires_at,
          created_at: notice.created_at
        }
      end
    end
  end
end
