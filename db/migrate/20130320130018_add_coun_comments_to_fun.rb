class AddCounCommentsToFun < ActiveRecord::Migration
  def change
    add_column :funs, :comments_counter, :integer, :default => 0
    add_index  :funs, :comments_counter
  end
end
