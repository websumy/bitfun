class CreateFuns < ActiveRecord::Migration
  def change
    create_table :funs do |t|
      t.string :title
      t.boolean :published
      t.integer :user_id
      t.integer :content_id
      t.string :content_type

      t.timestamps
    end

    add_index  :funs, :user_id
  end
end
