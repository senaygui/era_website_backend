class AddContactInformationToAboutUs < ActiveRecord::Migration[8.0]
  def change
    add_column :about_us, :contact_address, :text, default: "Ethiopian Roads Administration Building,\nAfrica Avenue (Bole Road),\nAddis Ababa, Ethiopia\nP.O. Box: 1770"
    add_column :about_us, :contact_phone_numbers, :text, default: "+251-115-15-04-19\n+251-111-56-23-94"
    add_column :about_us, :contact_fax_numbers, :text, default: "+251 11 554-44-34\n+251-111-55-12-95"
    add_column :about_us, :contact_emails, :text, default: "info@era.gov.et\nbids@era.gov.et\nhr@era.gov.et"
    add_column :about_us, :contact_working_hours, :text, default: "Monday to Friday: 8:30 AM - 5:30 PM\nSaturday: 8:30 AM - 12:30 PM\nSunday & Public Holidays: Closed"
    add_column :about_us, :contact_map_url, :string, default: "https://www.google.com/maps/search/?api=1&query=Ethiopian+Roads+Administration+Addis+Ababa"
  end
end
