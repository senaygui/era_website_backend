require "securerandom"

module FriendlySlug
  extend ActiveSupport::Concern

  class_methods do
    def has_friendly_slug(source: :title, fallback: model_name.singular, history: nil)
      validates :slug, presence: true, uniqueness: true

      before_validation do
        next unless new_record? || will_save_change_to_attribute?(source) || slug.blank?

        base = FriendlySlug.normalize(public_send(source))
        base = "#{fallback}-#{SecureRandom.hex(4)}" if base.blank?
        candidate = base
        suffix = 2
        scope = self.class.where.not(id: id)
        while scope.exists?(slug: candidate)
          candidate = "#{base}-#{suffix}"
          suffix += 1
        end
        if history && slug.present? && slug != candidate
          self[history] = (Array(self[history]) + [ slug ]).compact_blank.uniq
        end
        self.slug = candidate
      end
    end

    def find_by_slug_or_id(identifier)
      find_by(slug: identifier) || (find_by(id: identifier) if identifier.to_s.match?(/\A[0-9a-f-]{36}\z/i))
    end
  end

  def self.normalize(value)
    value.to_s.unicode_normalize(:nfkc).downcase
         .gsub(/[^\p{L}\p{N}]+/u, "-")
         .gsub(/\A-+|-+\z/, "")
  end
end
