class AddDiagnosisToVideoSessions < ActiveRecord::Migration
  def change
    add_column :video_sessions, :diagnosis, :string
  end
end
