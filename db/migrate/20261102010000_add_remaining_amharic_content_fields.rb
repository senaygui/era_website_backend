class AddRemainingAmharicContentFields < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :time_am, :string
    add_column :news, :tags_am, :text, array: true, default: []
    add_column :publications, :citation_information_am, :string
    add_column :road_assets, :citation_information_am, :string
    add_column :performance_reports, :citation_information_am, :string
  end
end
