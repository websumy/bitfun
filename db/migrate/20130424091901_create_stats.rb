class CreateStats < ActiveRecord::Migration
  def change
    create_table :stats do |t|
      t.integer :user_id

      t.integer :day_votes,     :default => 0
      t.integer :week_votes,    :default => 0
      t.integer :month_votes,   :default => 0
      t.integer :all_votes,     :default => 0

      t.integer :day_funs,      :default => 0
      t.integer :week_funs,     :default => 0
      t.integer :month_funs,    :default => 0
      t.integer :all_funs,      :default => 0

      t.integer :day_reposts,   :default => 0
      t.integer :week_reposts,  :default => 0
      t.integer :month_reposts, :default => 0
      t.integer :all_reposts,   :default => 0

      t.integer :day_followers,   :default => 0
      t.integer :week_followers,  :default => 0
      t.integer :month_followers, :default => 0
      t.integer :all_followers,   :default => 0

    end

    add_index :stats, :day_votes
    add_index :stats, :week_votes
    add_index :stats, :month_votes
    add_index :stats, :all_votes

    add_index :stats, :day_funs
    add_index :stats, :week_funs
    add_index :stats, :month_funs
    add_index :stats, :all_funs

    add_index :stats, :day_reposts
    add_index :stats, :week_reposts
    add_index :stats, :month_reposts
    add_index :stats, :all_reposts

    add_index :stats, :day_followers
    add_index :stats, :week_followers
    add_index :stats, :month_followers
    add_index :stats, :all_followers

  end
end