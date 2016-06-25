class OnlineVisit < ActiveRecord::Base
  validates_presence_of :user_id
  belongs_to :user
  belongs_to :csr, class_name: 'User'
  has_one :video_session, foreign_key: :call_back_id
  validate :scheduled_time_overlap

  def scheduled_time=(value)
    if value.is_a? (String)
      self.scheduled_time = Time.zone.parse(value)
    else
      super
    end
  end

  def scheduled_time_overlap
    if OnlineVisit.where(scheduled_time: self.scheduled_time).count > 0
      errors.add(:scheduled_time, "can't be overlapped")
    end
  end

  def attributes
    a = super
    a[:user_name] = nil
    a[:csr_name] = nil
    a
  end

  def user_name
    user.try(:name)
  end

  def csr_name
    csr.try(:name)
  end 

end
