class AddVideoIdToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :video_id, :string, :limit => 20
    add_column :videos, :video_type, :string, :limit => 20
  end
end
