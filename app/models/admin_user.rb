class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable, :trackable
  has_one_attached :photo, dependent: :destroy

    # #validations
    # validates :username , :presence => true,:length => { :within => 2..50 }
    validates :first_name, presence: true, length: { within: 2..50 }
    validates :last_name, presence: true, length: { within: 1..50 }
    validates :role, presence: true
    # validates :photo, attached: true, content_type: ['image/gif', 'image/png', 'image/jpg', 'image/jpeg']

    before_validation do
      self.role = role.to_s.downcase.presence
    end

    def self.ransackable_attributes(auth_object = nil)
      [ "created_at", "current_sign_in_at", "current_sign_in_ip", "email", "encrypted_password", "first_name", "id", "id_value", "last_name", "last_sign_in_at", "last_sign_in_ip", "middle_name", "remember_created_at", "reset_password_sent_at", "reset_password_token", "role", "sign_in_count", "updated_at", "username" ]
    end

    ## scope

    scope :recently_added, lambda { where("created_at >= ?", 1.week.ago) }
    scope :total_users, lambda { order("created_at DESC") }
    scope :admins, lambda { where(role: "admin") }


      def full_name
        [ first_name, middle_name.presence, last_name.presence ].compact.join(" ")
      end
end

