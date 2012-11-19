class CreateFunsTags < ActiveRecord::Migration
  def change
    create_table :funs_tags, :id => false do |t|
      t.integer :fun_id
      t.integer :tag_id
    end
    add_index :funs_tags, :fun_id
    add_index :funs_tags, :tag_id
  end
end