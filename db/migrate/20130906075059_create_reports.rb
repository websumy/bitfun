class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.text :abuse
      t.integer :fun_id
      t.integer :user_id

      t.timestamps
    end
  end
end
