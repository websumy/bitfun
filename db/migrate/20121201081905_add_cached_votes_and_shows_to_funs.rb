class AddCachedVotesAndShowsToFuns < ActiveRecord::Migration
  def self.up
    add_column :funs, :cached_votes_total, :integer, :default => 0
    add_column :funs, :cached_shows, :integer, :default => 0
    add_index  :funs, :cached_votes_total
    add_index  :funs, :cached_shows
  end

  def self.down
    remove_column :funs, :cached_votes_total
    remove_column :funs, :cached_shows
  end
end
