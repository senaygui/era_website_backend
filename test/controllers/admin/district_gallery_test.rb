require "test_helper"
require "base64"

class Admin::DistrictGalleryTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  self.fixture_table_names = []

  setup do
    sign_in AdminUser.create!(email: "gallery-admin@example.com", password: "Gallery-test-password1!",
                              first_name: "Gallery", last_name: "Admin", role: "admin"), scope: :admin_user
    @district = District.create!(name: "Gallery district")
  end

  test "creates a district with multiple gallery images" do
    post admin_districts_path, params: { district: {
      name: "New gallery district", gallery_images: [ "", upload("one.png"), upload("two.png") ]
    } }

    assert_response :redirect
    assert_equal 2, District.find_by!(name: "New gallery district").gallery_images.count
  end

  test "adds multiple gallery images without replacing existing files" do
    @district.gallery_images.attach(upload("original.png"))

    patch admin_district_path(@district), params: { district: {
      gallery_images: [ "", upload("one.png"), upload("two.png") ]
    } }

    assert_response :redirect
    assert_equal %w[one.png original.png two.png], @district.reload.gallery_images.map { |image| image.filename.to_s }.sort
  end

  test "empty file selection preserves the gallery" do
    @district.gallery_images.attach(upload("original.png"))

    patch admin_district_path(@district), params: { district: { gallery_images: [ "" ] } }

    assert_response :redirect
    assert_equal 1, @district.reload.gallery_images.count
  end

  test "edit form provides multiple upload and file management controls" do
    @district.gallery_images.attach(upload("original.png"))

    get edit_admin_district_path(@district)

    assert_response :success
    assert_select 'input[type=file][multiple][data-district-gallery]'
    assert_select "a", text: "Download"
    assert_select "a[data-method=post]", text: "Remove"
  end

  test "removes only the selected gallery image" do
    @district.gallery_images.attach([ upload("one.png"), upload("two.png") ])
    attachment = @district.gallery_images.first

    post remove_gallery_image_admin_district_path(@district), params: { attachment_id: attachment.id }

    assert_redirected_to edit_admin_district_path(@district)
    assert_equal 1, @district.reload.gallery_images.count
    assert_not @district.gallery_images.exists?(attachment.id)
  end

  test "cannot remove another district's gallery image" do
    other = District.create!(name: "Other gallery district")
    other.gallery_images.attach(upload("other.png"))

    post remove_gallery_image_admin_district_path(@district), params: { attachment_id: other.gallery_images.first.id }

    assert_response :not_found
    assert_equal 1, other.reload.gallery_images.count
  end

  private

  def upload(filename)
    png = Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=")
    Rack::Test::UploadedFile.new(StringIO.new(png), "image/png", original_filename: filename)
  end
end
