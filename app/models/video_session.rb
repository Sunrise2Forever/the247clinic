class VideoSession < ActiveRecord::Base
  validates_presence_of :symptom, :user_id
  belongs_to :user
  belongs_to :doctor, class_name: 'User'
  belongs_to :call_back
  has_many :photos
  has_one :opentok_session

  scope :pending, -> { where(status: :pending) }
  scope :started, -> { where(status: :started) }
  scope :waiting, -> { where(status: :waiting) }

  after_create :video_session_created
  after_update :video_session_updated

  def set_pending_timeout
    Delayed::Job.enqueue(PendingVideoSession.new(self.id), run_at: 15.minutes.from_now)
  end

  def video_session_updated
    if status_changed? and self.status == 'pending'
      set_pending_timeout
    end
  end

  def video_session_created
    if self.status == 'pending'
      set_pending_timeout
    end
  end
end
