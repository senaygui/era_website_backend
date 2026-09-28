module Api
  module V1
    class FeaturedSectionsController < BaseController
      def index
        page_key = params[:page].to_s
        unless FeaturedSection::PAGE_OPTIONS.value?(page_key) && page_key != "all"
          return render json: { error: "Unsupported page" }, status: :bad_request
        end

        sections = FeaturedSection.published
                                  .for_page(page_key)
                                  .ordered
                                  .includes(main_photo_attachment: :blob)

        render json: sections.map { |section| section_json(section) }
      end

      private

      def section_json(section)
        {
          id: section.id,
          title: section.title,
          description: section.description,
          cta_label: section.cta_label,
          cta_url: section.cta_url,
          section_position: section.section_position,
          display_order: section.display_order,
          main_photo_url: url_for(section.main_photo)
        }
      end
    end
  end
end
