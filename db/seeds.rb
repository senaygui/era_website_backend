# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Ensure singleton Road Research Center exists
RoadResearchCenter.instance

if Rails.env.development?
  admin_email = ENV["ADMIN_EMAIL"]
  admin_password = ENV["SEED_PASSWORD"]

  if admin_email.present? && admin_password.present?
    AdminUser.find_or_create_by!(email: admin_email) do |admin|
      admin.password = admin_password
      admin.password_confirmation = admin_password
      admin.role = ENV.fetch("ROLE", "admin")
      admin.first_name = ENV.fetch("FIRST_NAME", "Development")
      admin.middle_name = ENV["MIDDLE_NAME"]
      admin.last_name = ENV.fetch("LAST_NAME", "Administrator")
    end
  else
    warn "Skipping development admin seed: ADMIN_EMAIL and SEED_PASSWORD are required"
  end
end

# Production provisioning must receive a unique secret from the deployment
# environment. Never add a fallback password here.
if Rails.env.production?
  admin_email = ENV.fetch("ADMIN_EMAIL")
  admin_password = ENV.fetch("ADMIN_PASSWORD")
  raise "ADMIN_PASSWORD must be at least 16 characters" if admin_password.length < 16
  unless AdminUser.exists?(email: admin_email)
    AdminUser.create!(
      email: admin_email,
      password: admin_password,
      password_confirmation: admin_password,
      role: 'admin',
      first_name: 'Production',
      last_name: 'Admin'
    )
    puts "Created the production administrator"
  end
end
