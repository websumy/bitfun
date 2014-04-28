class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|

      t.string :action
      t.references :subject, polymorphic: true
      t.references :target, polymorphic: true
      t.integer :user_id
      t.integer :receiver_id
      t.integer :fun_id

      t.timestamp :created_at
    end

    add_index :notifications, [:subject_id, :subject_type]
    add_index :notifications, :user_id
  end
end
