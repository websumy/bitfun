class AddAuthorId < ActiveRecord::Migration
  def self.up
    add_column :funs, :author_id, :integer
    add_index  :funs, :author_id
  end

  def self.down
    remove_column :funs, :author_id
  end
end
