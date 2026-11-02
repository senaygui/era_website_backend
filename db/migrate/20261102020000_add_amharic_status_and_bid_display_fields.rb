class AddAmharicStatusAndBidDisplayFields < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :status_am, :string
    add_column :projects, :status_am, :string
    add_column :bids, :status_am, :string
    add_column :bids, :budget_am, :string
    add_column :bids, :contract_value_am, :string
    add_column :publications, :status_am, :string
    add_column :road_assets, :status_am, :string
    add_column :performance_reports, :status_am, :string
  end
end
