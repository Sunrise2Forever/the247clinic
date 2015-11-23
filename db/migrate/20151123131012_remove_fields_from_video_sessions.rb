class RemoveFieldsFromVideoSessions < ActiveRecord::Migration
  def change
    remove_column :video_sessions, :message, :string
    remove_column :video_sessions, :callback, :string
  end
end
