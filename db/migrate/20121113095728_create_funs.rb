class CreateFuns < ActiveRecord::Migration
  def change
    create_table :funs do |t|
      t.string :name
      t.string :string
      t.integer :user_id

      t.timestamps
    end

    add_index  :funs, :user_id
  end
end
