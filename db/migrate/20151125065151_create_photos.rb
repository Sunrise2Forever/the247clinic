class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.integer :video_session_id
      t.string :photo_url

      t.timestamps null: false
    end
  end
end
