class AboutUs < ApplicationRecord
  # Set the table name explicitly since Rails would expect 'about_uses'
  self.table_name = "about_us"
  # ActiveStorage attachments
  has_one_attached :hero_image
  has_one_attached :mission_image
  has_one_attached :vision_image
  has_one_attached :history_image
  has_one_attached :org_structure_image
  has_many_attached :team_images

  def self.ransackable_associations(auth_object = nil)
    [ "hero_image_attachment", "hero_image_blob", "history_image_attachment", "history_image_blob", "mission_image_attachment", "mission_image_blob", "org_structure_image_attachment", "org_structure_image_blob", "team_images_attachments", "team_images_blobs", "vision_image_attachment", "vision_image_blob" ]
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "achievements", "achievements_description", "created_at", "description", "history", "id", "is_published", "meta_description", "meta_keywords", "meta_title", "milestones", "milestones_description", "mission", "partners", "subtitle", "team_description", "team_members", "title", "updated_at", "values", "values_title", "vision" ]
  end


  # Validations
  validates :title, presence: true
  validates :description, presence: true

  # Validate image content types
  validate :validate_image_content_types

  # Class methods
  def self.instance
    first_or_create(title: "About Us", description: "About Us description")
  end

  # Instance methods
  def achievements_list
    return [] if achievements.nil? || achievements.empty?
    return JSON.parse(achievements) if achievements.is_a?(String)
    achievements
  end

  def milestones_list
    return [] if milestones.nil? || milestones.empty?
    return JSON.parse(milestones) if milestones.is_a?(String)
    milestones
  end

  def partners_list
    return [] if partners.nil? || partners.empty?
    return JSON.parse(partners) if partners.is_a?(String)
    partners
  end

  def team_members_list
    return [] if team_members.nil? || team_members.empty?
    return JSON.parse(team_members) if team_members.is_a?(String)
    team_members
  end
  
  def values_list
    return [] if values.nil? || values.empty?
    
    if values.is_a?(String)
      begin
        # Try to parse as JSON
        return JSON.parse(values)
      rescue JSON::ParserError
        # If not valid JSON, parse as plain text
        lines = values.split("\n")
        result = []
        
        # Process each pair of lines (title and description)
        i = 0
        while i < lines.length
          title = lines[i].strip
          description = lines[i + 1]&.strip || ""
          
          # Skip empty lines
          if !title.empty?
            result << { "title" => title, "description" => description }
          end
          
          # Move to the next pair
          i += 2
        end
        
        return result
      end
    end
    
    # If it's already an array, return it
    values.is_a?(Array) ? values : []
  end

  private

  def validate_image_content_types
    [ hero_image, mission_image, vision_image, history_image, org_structure_image ].each do |image|
      if image.attached? && !image.content_type.in?(%w[image/jpeg image/png image/gif])
        errors.add(image.name, "must be a JPEG, PNG, or GIF")
      end
    end

    team_images.each do |image|
      unless image.content_type.in?(%w[image/jpeg image/png image/gif])
        errors.add(:team_images, "must be a JPEG, PNG, or GIF")
      end
    end
  end
end
