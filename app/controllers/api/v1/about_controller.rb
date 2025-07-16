module Api
  module V1
    class AboutController < Api::ApiController
      def index
        @about = AboutUs.instance
        
        render json: {
          title: @about.title,
          subtitle: @about.subtitle,
          description: @about.description,
          mission: @about.mission,
          vision: @about.vision,
          values_title: @about.values_title,
          values: @about.values.is_a?(Array) ? @about.values : @about.values_list,
          history: @about.history,
          team_description: @about.team_description,
          team_members: @about.team_members_list,
          achievements_description: @about.achievements_description,
          achievements: @about.achievements_list,
          milestones_description: @about.milestones_description,
          milestones: @about.milestones_list,
          partners: @about.partners_list,
          hero_image_url: @about.hero_image.attached? ? url_for(@about.hero_image) : nil,
          mission_image_url: @about.mission_image.attached? ? url_for(@about.mission_image) : nil,
          vision_image_url: @about.vision_image.attached? ? url_for(@about.vision_image) : nil,
          history_image_url: @about.history_image.attached? ? url_for(@about.history_image) : nil,
          org_structure_image_url: @about.org_structure_image.attached? ? url_for(@about.org_structure_image) : nil,
          team_images_urls: @about.team_images.attached? ? @about.team_images.map { |img| url_for(img) } : [],
          meta: {
            title: @about.meta_title,
            description: @about.meta_description,
            keywords: @about.meta_keywords
          }
        }
      end
    end
  end
end
