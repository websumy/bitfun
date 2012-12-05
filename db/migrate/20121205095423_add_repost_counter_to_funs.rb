class AddRepostCounterToFuns < ActiveRecord::Migration
  def self.change
    add_column :funs, :repost_counter, :integer, :default => 0
    add_index  :funs, :repost_counter
  end
end
