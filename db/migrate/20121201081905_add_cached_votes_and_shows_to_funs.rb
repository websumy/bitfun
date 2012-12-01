class AddCachedVotesAndShowsToFuns < ActiveRecord::Migration
  def self.up
    add_column :funs, :cached_votes, :integer, :default => 0
    add_column :funs, :cached_shows, :integer, :default => 0
    add_index  :funs, :cached_votes
    add_index  :funs, :cached_shows
  end

  def self.down
    remove_column :funs, :cached_votes
    remove_column :funs, :cached_shows
  end
end
