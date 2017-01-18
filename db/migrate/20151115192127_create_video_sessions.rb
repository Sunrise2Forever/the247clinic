class CreateVideoSessions < ActiveRecord::Migration
  def change
    create_table :video_sessions do |t|
      t.integer :user_id
      t.text :symptom
      t.datetime :start_time
      t.datetime :finish_time
      t.text :message
      t.text :callback
      t.text :feedback
      t.text :notes
      t.integer :doctor_id
      t.string :status

      t.timestamps null: false
    end
  end
end
