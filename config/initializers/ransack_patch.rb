# frozen_string_literal: true

# This initializer adds ransackable_attributes and ransackable_associations methods to ActiveStorage models
Rails.application.config.after_initialize do
  if defined?(ActiveStorage)
    # For ActiveStorage::Attachment
    if defined?(ActiveStorage::Attachment)
      ActiveStorage::Attachment.class_eval do
        def self.ransackable_attributes(auth_object = nil)
          ["blob_id", "created_at", "id", "name", "record_id", "record_type"]
        end
        
        def self.ransackable_associations(auth_object = nil)
          ["blob", "record"]
        end
      end
    end

    # For ActiveStorage::Blob
    if defined?(ActiveStorage::Blob)
      ActiveStorage::Blob.class_eval do
        def self.ransackable_attributes(auth_object = nil)
          ["byte_size", "checksum", "content_type", "created_at", "filename", "id", "key", "metadata", "service_name"]
        end
        
        def self.ransackable_associations(auth_object = nil)
          ["attachments", "variant_records"]
        end
      end
    end

    # For ActiveStorage::VariantRecord
    if defined?(ActiveStorage::VariantRecord)
      ActiveStorage::VariantRecord.class_eval do
        def self.ransackable_attributes(auth_object = nil)
          ["blob_id", "created_at", "id", "variation_digest"]
        end
        
        def self.ransackable_associations(auth_object = nil)
          ["blob", "image_attachment", "image_blob"]
        end
      end
    end
  end
end
