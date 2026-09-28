class AddYoutubeUrlToNews < ActiveRecord::Migration[8.0]
  def change
    add_column :news, :youtube_url, :string
  end
end
