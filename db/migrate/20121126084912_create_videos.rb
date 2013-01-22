class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :title
      t.string :video_id, :limit => 20
      t.string :video_type, :limit => 20
      t.string :url
      t.string :image
      t.string :cached_tag_list
    end
  end
end
