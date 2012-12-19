class AddCachedTagListToImageVideoPost < ActiveRecord::Migration
  def change
    add_column :images, :cached_tag_list, :string
    add_column :videos, :cached_tag_list, :string
    add_column :posts,  :cached_tag_list, :string
  end
end
