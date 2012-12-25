class AddColumsToUser < ActiveRecord::Migration
  def change
    add_column :users, :location, :string
    add_column :users, :info, :text
    add_column :users, :site, :string
    add_column :users, :vk_link, :string
    add_column :users, :fb_link, :string
    add_column :users, :tw_link, :string
  end
end
