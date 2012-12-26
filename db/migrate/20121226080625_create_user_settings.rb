class CreateUserSettings < ActiveRecord::Migration
  def change
    create_table :user_settings do |t|
      t.text :info
      t.string :location
      t.string :site
      t.string :vk_link
      t.string :fb_link
      t.string :tw_link
      t.integer :sex
      t.date :birthday
      t.references :user
    end
  end
end
