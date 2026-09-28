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
        gallery = center.road_research_gallery_images.published.ordered.includes(image_attachment: :blob).filter_map do |item|
          next unless item.image.attached?

          {
            id: item.id,
            title: item.title,
            caption: item.caption,
            position: item.position,
            image_url: attachment_url(item.image)
          }
        end

        technologies = center.road_research_technologies.where(is_published: true).order(:created_at).map do |t|
          {
            id: t.id,
            title: t.title,
            category: t.category,
            description: t.description,
            status: t.status,
            is_published: t.is_published
          }
        end

        laboratory_services = center.road_research_laboratory_services.where(is_published: true).order(:created_at).map do |s|
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
          hero_headline: center.hero_headline.presence || center.title,
          hero_subheadline: center.hero_subheadline,
          hero_image_url: center.hero_image.attached? ? attachment_url(center.hero_image) : nil,
          about: center.about,
          vision: center.vision,
          mission: center.mission,
          objectives: center.objectives,
          organizational_structure: center.organizational_structure,
          organizational_structure_image_url: center.organizational_structure_image.attached? ? attachment_url(center.organizational_structure_image) : nil,
          contact: {
            address: center.contact_address,
            phone: center.contact_phone,
            email: center.contact_email,
            hours: center.contact_hours,
            map_url: center.contact_map_url
          },
          gallery: gallery,
          gallery_images_urls: gallery.map { |item| item[:image_url] },
          technologies: technologies,
          laboratory_services: laboratory_services,
          meta: {
            title: center.meta_title,
            description: center.meta_description,
            keywords: center.meta_keywords
          }
        }
      end

      def attachment_url(attachment)
        rails_blob_url(attachment, host: request.base_url, disposition: "inline")
      end
    end
  end
end
