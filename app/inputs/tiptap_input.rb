class TiptapInput < Formtastic::Inputs::TextInput
  def input_html_options
    options = super
    options[:class] = Array(options[:class]).append("aa-tiptap-input").compact.join(" ")
    options[:data] = (options[:data] || {}).merge(editor_upload_url: "/admin/editor_uploads")
    options
  end
end
