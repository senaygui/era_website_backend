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

# Create test news articles
puts "Creating test news articles..."

5.times do |i|
  news = News.create!(
    title: "Test News Article #{i + 1}",
    content: "This is the content of test news article #{i + 1}. It contains some sample text for testing purposes.",
    excerpt: "A brief excerpt from test news article #{i + 1}",
    published_date: Time.current - i.days,
    category: [ "Technology", "Science", "Business", "Politics", "Sports" ][i % 5],
    tags: [ "test", "sample", "article-#{i + 1}" ],
    is_featured: i == 0,
    view_count: rand(100),
    author: "Test Author",
    is_published: true
  )
  puts "Created news article: #{news.title}"
end

puts "Seed data created successfully!"
