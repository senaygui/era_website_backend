require "test_helper"

class Api::V1::ContactMessagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  self.fixture_table_names = []

  setup do
    @attributes = { name: " Test Visitor ", email: "visitor@example.com", phone: "",
                    subject: "Road inquiry", department: "general", message: "Please send details.", consent: true }
  end

  test "stores a public submission and acknowledges receipt without exposing personal information" do
    assert_difference "ContactMessage.count", 1 do
      post api_v1_contact_messages_path, params: { contact_message: @attributes }, as: :json
    end
    assert_response :created
    assert_equal "Test Visitor", ContactMessage.order(:created_at).last.name
    assert_equal ["message"], response.parsed_body.keys
  end

  test "rejects invalid fields and missing consent without saving" do
    [ { name: " " }, { email: "invalid" }, { subject: " " }, { message: " " },
      { department: "unknown" }, { consent: false }, { message: "a" * 10_001 } ].each do |invalid|
      assert_no_difference "ContactMessage.count" do
        post api_v1_contact_messages_path, params: { contact_message: @attributes.merge(invalid) }, as: :json
      end
      assert_response :unprocessable_entity
      assert response.parsed_body["error"].present?
    end
  end

  test "requires the submission payload" do
    post api_v1_contact_messages_path, params: {}, as: :json
    assert_response :bad_request
  end

  test "admin inbox requires authentication" do
    get admin_contact_messages_path
    assert_redirected_to new_admin_user_session_path
  end

  test "admin can read received messages" do
    message = ContactMessage.create!(@attributes)
    sign_in AdminUser.create!(email: "contact-admin@example.com", password: "Contact-test-password1!",
                              first_name: "Contact", last_name: "Admin", role: "admin"), scope: :admin_user
    get admin_contact_messages_path
    assert_response :success
    assert_select "td", text: "Road inquiry"
    # Authenticate this request explicitly; the app installs session middleware twice.
    sign_in AdminUser.find_by!(email: "contact-admin@example.com"), scope: :admin_user
    get admin_contact_message_path(message)
    assert_response :success
    assert_select "p", text: "Please send details."
  end
end
