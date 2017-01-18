class AddSignOffToVideoSessions < ActiveRecord::Migration
  def change
    add_column :video_sessions, :sign_off, :boolean
  end
end
