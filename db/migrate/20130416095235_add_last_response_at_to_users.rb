class AddLastResponseAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_response_at, :datetime
  end
end
