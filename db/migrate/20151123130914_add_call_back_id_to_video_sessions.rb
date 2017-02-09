class AddCallBackIdToVideoSessions < ActiveRecord::Migration
  def change
    add_column :video_sessions, :call_back_id, :integer
  end
end
