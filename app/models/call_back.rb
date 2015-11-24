class CallBack < ActiveRecord::Base
  validates_presence_of :user_id
  belongs_to :user
  belongs_to :doctor, class_name: 'User'
  has_one :video_session

  def scheduled_time=(value)
    if value.is_a? (String)
      self.scheduled_time = Time.zone.parse(value)
    else
      super
    end
  end
end
