class CreateFuns < ActiveRecord::Migration
  def change
    create_table :funs do |t|
      t.integer :user_id
      t.integer :parent_id
      t.integer :owner_id
      t.integer :content_id
      t.string :content_type

      t.integer :repost_counter, :default => 0
      t.integer :cached_votes_total, :default => 0

      t.timestamp :published_at
      t.timestamps
    end

    add_index  :funs, :user_id
    add_index  :funs, :repost_counter
    add_index  :funs, :cached_votes_total
  end
end
