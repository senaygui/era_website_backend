ActiveAdmin.register District do
  permit_params :main_image, :meta_description, :meta_title, :district_overview, :detail_description, :is_published, :name, :address, :published_by, :updated_by, :map_embed, phone_numbers: [], emails: [], social_media_links: [], meta_keywords: [], gallery_images: []


  index do
    selectable_column
    column(:name)    { |r| content_tag(:span, truncate(r.name.to_s, length: 60),   title: r.name.to_s) }
    column(:address) { |r| content_tag(:span, truncate(r.address.to_s, length: 60), title: r.address.to_s) }
    column :is_published
    actions
  end

  filter :name
  filter :is_published

  show do
    attributes_table do
      row :name
      row :address
      row :map_embed
      row :phone_numbers do |district|
        district.phone_numbers.join(", ")
      end
      row :emails do |district|
        district.emails.join(", ")
      end
      row :social_media_links do |district|
        district.social_media_links.join(", ")
      end
      row :district_overview
      row :detail_description
      row :main_image do |district|
        if district.main_image.attached?
          div class: "main-image-container" do
            image_tag(district.main_image, size: "500x500", class: "img-corner")
          end
        end
      end

      row :gallery_images do |district|
        if district.gallery_images.attached?
          div class: "gallery-grid" do
            district.gallery_images.each do |img|
              div class: "gallery-item" do
                image_tag(img, size: "300x300", class: "img-corner")
              end
            end
          end
        end
      end
      row :is_published
      row :meta_title
      row :meta_description
      row :meta_keywords do |district|
        district.meta_keywords.join(", ")
      end
      row :published_by
      row :updated_by
    end
    active_admin_comments
  end

  form do |f|
    f.inputs "District Informations" do
      f.input :name
      f.input :district_overview
      f.input :detail_description
      f.input :address
      f.input :map_embed
      f.input :phone_numbers, as: :text,
        input_html: {
          value: f.object.phone_numbers.join("\n"),
          rows: 5
        },
        hint: "Enter one phone number per line"
      f.input :emails, as: :text,
        input_html: {
          value: f.object.emails.join("\n"),
          rows: 5
        },
        hint: "Enter one email per line"
      f.input :social_media_links, as: :text,
        input_html: {
          value: f.object.social_media_links.join("\n"),
          rows: 5
        },
        hint: "Enter one social media link per line"
      f.input :main_image, as: :file
      f.input :gallery_images, as: :file, input_html: { multiple: true }
      f.input :is_published
      f.input :meta_title
      f.input :meta_description
      f.input :meta_keywords, as: :text,
        input_html: {
          value: f.object.meta_keywords.join("\n"),
          rows: 5
        },
        hint: "Enter one meta keyword per line"
      if f.object.new_record?
          f.input :published_by, as: :hidden, input_html: { value: current_admin_user.full_name }
      else
          f.input :updated_by, as: :hidden, input_html: { value: current_admin_user.full_name }
      end
    end
    f.actions
  end
end
