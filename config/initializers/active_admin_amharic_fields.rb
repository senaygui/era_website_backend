# Adds a consistent Amharic section to every ActiveAdmin form backed by a
# LocalizedContent model, including existing custom forms.
module ActiveAdminAmharicFormFields
  def actions(*args, &block)
    add_amharic_inputs unless instance_variable_defined?(:@amharic_inputs_added)
    super
  end

  private

  def add_amharic_inputs
    @amharic_inputs_added = true
    names = object.class.respond_to?(:localized_attribute_names) ? object.class.localized_attribute_names : []
    return if names.empty?

    inputs "Amharic translation (አማርኛ)" do
      names.each do |name|
        column = object.class.columns_hash[name.to_s]
        options = { label: "#{name.to_s.humanize} (አማርኛ)", required: true }
        if column&.type.in?([ :text, :jsonb ]) || column&.array
          options[:as] = :text
          options[:input_html] = { rows: 4, class: "aa-plain-text", required: true }
          current_value = object.public_send("#{name}_am")
          options[:input_html][:value] = Array(current_value).join("\n") if column&.array
          options[:input_html][:value] = current_value.to_json if column&.type == :jsonb && current_value.present?
        end
        input "#{name}_am", **options
      end
    end
  end
end

# Existing permit_params declarations do not know about fields supplied by the
# shared translation form. Copy only the explicitly declared translation keys
# into the already-permitted resource hash.
module ActiveAdminAmharicParameters
  def permitted_params
    permitted = super
    model = active_admin_config.resource_class
    names = model.respond_to?(:localized_attribute_names) ? model.localized_attribute_names : []
    key = active_admin_config.param_key.to_s
    submitted = params[key]
    target = permitted[key]

    if submitted.respond_to?(:[]) && target.respond_to?(:[]=)
      names.each do |name|
        translated_key = "#{name}_am"
        target[translated_key] = submitted[translated_key] if submitted.key?(translated_key)
      end
    end

    permitted
  end
end

Rails.application.config.after_initialize do
  ActiveAdmin::FormBuilder.prepend(ActiveAdminAmharicFormFields) unless ActiveAdmin::FormBuilder < ActiveAdminAmharicFormFields
  ActiveAdmin::ResourceController.prepend(ActiveAdminAmharicParameters) unless ActiveAdmin::ResourceController < ActiveAdminAmharicParameters
end
