class RemoveCachedShowsFromFuns < ActiveRecord::Migration
  def up
    rename_column :funs, :cached_shows, :repost_count
  end

  def down
    rename_column :funs, :repost_count, :cached_shows
  end
end
