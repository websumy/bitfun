class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :title
      t.string :file
      t.string :url
      t.string :cached_tag_list
    end
  end
end
