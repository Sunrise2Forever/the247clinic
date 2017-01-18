class CreateOpentokSessions < ActiveRecord::Migration
  def change
    create_table :opentok_sessions do |t|
      t.references :video_session, index: true, foreign_key: true
      t.string :session_id
      t.string :token
      t.string :e

      t.timestamps null: false
    end
  end
end
