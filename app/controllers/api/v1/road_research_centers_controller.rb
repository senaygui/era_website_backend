module Api
  module V1
    class RoadResearchCentersController < Api::ApiController
      def index
        center = RoadResearchCenter.instance
        render json: center_json(center)
      end

      def show
        center = RoadResearchCenter.instance
        render json: center_json(center)
      end

      private

      def center_json(center)
        gallery_urls = if center.gallery_images.attached?
          center.gallery_images.map { |img| url_for(img) }
        else
          []
        end

        technologies = center.road_research_technologies.map do |t|
          {
            id: t.id,
            title: t.title,
            category: t.category,
            description: t.description,
            status: t.status,
            is_published: t.is_published
          }
        end

        laboratory_services = center.road_research_laboratory_services.map do |s|
          {
            id: s.id,
            title: s.title,
            category: s.category,
            description: s.description,
            status: s.status,
            is_published: s.is_published
          }
        end

        {
          id: center.id,
          title: center.title,
          about: center.about,
          gallery_images_urls: gallery_urls,
          technologies: technologies,
          laboratory_services: laboratory_services,
          meta: {
            title: center.meta_title,
            description: center.meta_description,
            keywords: center.meta_keywords
          }
        }
      end
    end
  end
end
