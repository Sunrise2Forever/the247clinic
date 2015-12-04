class Appointment < ActiveRecord::Base
  validates_presence_of  :start_time, :end_time
  scope :active, -> { where(status: :active) }
  belongs_to :user
  belongs_to :clinic
  belongs_to :doctor

  validate :time_range

  def time_range
    if start_time and end_time
      errors.add(:start_time, "must be smaller than End time") if (DateTime.parse(start_time.to_s) >= DateTime.parse(end_time.to_s))
    end
  end

end
