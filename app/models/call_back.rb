class CallBack < ActiveRecord::Base
  validates_presence_of :user_id
  belongs_to :user
  belongs_to :doctor, class_name: 'User'
  has_one :video_session

  after_save :notify_meeting_request

  def scheduled_time=(value)
    if value.is_a? (String)
      self.scheduled_time = Time.zone.parse(value)
    else
      super
    end
  end

  def notify_meeting_request
    if self.scheduled_time.present?
      CallBackMailer.meeting_request_doctor(self).deliver
      CallBackMailer.meeting_request_user(self).deliver
    end
  end
end
