require "action_view"

module SeoMetadataSync
  extend ActiveSupport::Concern

  class_methods do
    def syncs_seo_metadata(title:, description:, keywords: [])
      define_method(:seo_title_source) { public_send(title) }
      define_method(:seo_description_sources) { Array(description).map { |attribute| public_send(attribute) } }
      define_method(:seo_keyword_sources) { Array(keywords).flat_map { |attribute| Array(public_send(attribute)) } }

      before_validation :sync_seo_metadata
    end
  end

  private

  def sync_seo_metadata
    generated_title = seo_plain_text(seo_title_source)
    generated_description = seo_description_sources.filter_map do |value|
      text = seo_plain_text(value)
      text if text.present?
    end.first.to_s.truncate(256)
    keywords = seo_keyword_sources.flat_map { |value| value.to_s.split(",") }
                                  .map { |value| seo_plain_text(value) }
                                  .compact_blank
                                  .uniq

    self.meta_title = generated_title unless seo_meta_manually_changed?(:meta_title)
    self.meta_description = generated_description unless seo_meta_manually_changed?(:meta_description)
    self.meta_keywords = seo_keywords_array? ? keywords : keywords.join(", ") unless seo_meta_manually_changed?(:meta_keywords)
  end

  def seo_meta_manually_changed?(attribute)
    will_save_change_to_attribute?(attribute) && public_send(attribute).present?
  end

  def seo_plain_text(value)
    ActionView::Base.full_sanitizer.sanitize(value.to_s).squish
  end

  def seo_keywords_array?
    self.class.type_for_attribute("meta_keywords").type.in?([ :json, :jsonb ]) ||
      self.class.columns_hash.fetch("meta_keywords").array?
  end
end
