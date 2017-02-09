class CreateCallBacks < ActiveRecord::Migration
  def change
    create_table :call_backs do |t|
      t.integer :user_id
      t.integer :doctor_id
      t.datetime :scheduled_time

      t.timestamps null: false
    end
  end
end
