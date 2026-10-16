require "test_helper"

class Api::V1::AboutControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  self.fixture_table_names = []

  setup do
    @about = AboutUs.instance
    @admin = AdminUser.create!(email: "about-contact-admin@example.com", password: "Contact-test-password1!",
                               first_name: "Contact", last_name: "Admin", role: "admin")
  end

  test "admin edits shared contact information and the public API returns it" do
    sign_in @admin, scope: :admin_user
    get edit_admin_about_us_path(@about)
    assert_response :success
    assert_select "textarea[name='about_us[contact_phone_numbers]']"
    assert_select "input[name='about_us[contact_map_url]']"

    sign_in @admin, scope: :admin_user
    patch admin_about_us_path(@about), params: { about_us: {
      contact_address: "New headquarters\nAddis Ababa",
      contact_phone_numbers: " +251 11 123 4567 \r\n\n+251 11 765 4321",
      contact_fax_numbers: " +251 11 111 1111 ",
      contact_emails: "contact@example.com\n\ninfo@example.com",
      contact_working_hours: "Monday to Friday: 9 AM - 5 PM",
      contact_map_url: "https://maps.example.com/headquarters"
    } }
    assert_redirected_to admin_about_us_path(@about)

    get api_v1_about_path, as: :json
    assert_response :success
    assert_equal({
      "address" => "New headquarters\nAddis Ababa",
      "phone_numbers" => ["+251 11 123 4567", "+251 11 765 4321"],
      "fax_numbers" => ["+251 11 111 1111"],
      "emails" => ["contact@example.com", "info@example.com"],
      "working_hours" => "Monday to Friday: 9 AM - 5 PM",
      "map_url" => "https://maps.example.com/headquarters"
    }, response.parsed_body.fetch("contact_information"))
  end

  test "map links allow web URLs or blanks and reject executable URLs" do
    ["javascript:alert(1)", "data:text/html,test", "https://", "not a URL"].each do |url|
      @about.contact_map_url = url
      assert_not @about.valid?, url
      assert @about.errors[:contact_map_url].present?
    end
    ["", "https://maps.example.com/location", "http://maps.example.com/location"].each do |url|
      @about.contact_map_url = url
      assert @about.valid?, @about.errors.full_messages.join(", ")
    end
    @about.update!(contact_phone_numbers: "", contact_fax_numbers: nil, contact_emails: "\n")
    get api_v1_about_path, as: :json
    assert_response :success
    assert_equal [], response.parsed_body.dig("contact_information", "phone_numbers")
    assert_equal [], response.parsed_body.dig("contact_information", "fax_numbers")
    assert_equal [], response.parsed_body.dig("contact_information", "emails")
  end
end
