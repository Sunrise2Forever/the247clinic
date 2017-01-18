class CreateOnlineVisits < ActiveRecord::Migration
  def change
    create_table :online_visits do |t|
      t.integer :user_id
      t.integer :csr_id
      t.datetime :scheduled_time

      t.timestamps null: false
    end
  end
end
