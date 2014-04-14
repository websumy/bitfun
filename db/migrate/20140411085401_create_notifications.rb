class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|

      t.string :action
      t.references :target, polymorphic: true
      t.integer :user_id
      t.integer :receiver_id

      t.timestamp :created_at
    end

    add_index :notifications, [:target_id, :target_type]
    add_index :notifications, :user_id
  end
end
