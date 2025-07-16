# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password', role: 'admin', first_name: "admin", last_name: "user") if Rails.env.development?
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?

# Create a default admin user for production if none exists
if Rails.env.production?
  admin_email =  'admin@production.com'
  admin_password = 'securepassword123'
  unless AdminUser.exists?(email: admin_email)
    AdminUser.create!(
      email: admin_email,
      password: admin_password,
      password_confirmation: admin_password,
      role: 'admin',
      first_name: 'Production',
      last_name: 'Admin'
    )
    puts "Created production admin user: \\#{admin_email}"
  end
end
