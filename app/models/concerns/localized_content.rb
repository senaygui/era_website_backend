module LocalizedContent
  extend ActiveSupport::Concern

  included do
    validate :amharic_translations_are_complete
  end

  class_methods do
    # Keeps the public API keys unchanged while selecting the translated value.
    # English remains the fallback for partially translated records.
    def localizes(*attribute_names)
      @localized_attribute_names = attribute_names.map(&:to_sym)

      attribute_names.each do |attribute_name|
        define_method(attribute_name) do
          if I18n.locale == :am
            translated = self["#{attribute_name}_am"]
            return translated if translated.present?
          end

          self[attribute_name]
        end


        define_method("#{attribute_name}_am=") do |value|
          original_column = self.class.columns_hash[attribute_name.to_s]
          value = value.to_s.lines.map(&:strip).reject(&:blank?) if original_column&.array && value.is_a?(String)
          if original_column&.type == :jsonb && value.is_a?(String)
            stripped = value.strip
            value = if stripped.start_with?("[", "{")
              JSON.parse(stripped)
            else
              stripped.lines.map(&:strip).reject(&:blank?)
            end
          end
          self["#{attribute_name}_am"] = value
        rescue JSON::ParserError
          self["#{attribute_name}_am"] = value
        end
      end
    end


    def localized_attribute_names
      @localized_attribute_names || []
    end
  end

  private

  def amharic_translations_are_complete
    self.class.localized_attribute_names.each do |attribute_name|
      translated_name = "#{attribute_name}_am"
      value = self[translated_name]

      if value.blank?
        errors.add(translated_name, "is required")
      elsif !contains_amharic_text?(value)
        errors.add(translated_name, "must contain Amharic text")
      end
    end
  end

  def contains_amharic_text?(value)
    value.to_json.match?(/\p{Ethiopic}/)
  end
end
