class AddAmharicContentFields < ActiveRecord::Migration[8.0]
  TRANSLATIONS = {
    about_us: %i[title subtitle description mission vision values_title values history team_description achievements achievements_description milestones milestones_description partners meta_title meta_description meta_keywords contact_address contact_working_hours],
    about_core_values: %i[title description],
    team_members: %i[name position job_title description],
    news: %i[title content excerpt category author meta_title meta_description meta_keywords],
    events: %i[title description excerpt location event_type agenda speakers meta_title meta_description meta_keywords],
    projects: %i[title description location contractor project_manager objectives scope milestones challenges meta_title meta_description meta_keywords],
    bids: %i[title category type_of_bid funding_source description eligibility contact_person award_status awarded_to],
    vacancies: %i[title department location job_type description salary requirements responsibilities benefits],
    districts: %i[name address district_overview detail_description meta_title meta_description meta_keywords],
    publications: %i[title category description authors meta_title meta_description meta_keywords],
    road_assets: %i[title category description authors meta_title meta_description meta_keywords],
    performance_reports: %i[title category description authors meta_title meta_description meta_keywords],
    featured_sections: %i[title description cta_label],
    urgent_notices: %i[notice_title notice_short_description],
    road_research_centers: %i[title hero_headline hero_subheadline about vision mission objectives organizational_structure contact_address contact_hours meta_title meta_description meta_keywords],
    road_research_gallery_images: %i[title caption],
    road_research_technologies: %i[title category description status],
    road_research_laboratory_services: %i[title category description status]
  }.freeze

  def change
    TRANSLATIONS.each do |table, attributes|
      attributes.each do |attribute|
        original = columns(table).find { |column| column.name == attribute.to_s }
        next unless original

        add_column table, "#{attribute}_am", original.type,
                   array: original.array,
                   default: original.array ? [] : nil
      end
    end
  end
end
