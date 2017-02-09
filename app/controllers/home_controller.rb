class HomeController < ApplicationController
  def index
    if logged_in?
      @call_back = CallBack.where('call_backs.user_id = ? OR call_backs.doctor_id = ?', current_user.id, current_user.id)
                     .where.not(scheduled_time: nil)
                     .joins('LEFT JOIN video_sessions ON call_backs.id = video_sessions.call_back_id')
                     .where("video_sessions.status IS NULL OR (video_sessions.status <> 'finished' AND video_sessions.status <> 'callback')").first
    end
  end
end
