class Appointment < ActiveRecord::Base
  validates_presence_of  :start_time, :end_time
  scope :active, -> { where(status: :active) }
  belongs_to :user
  belongs_to :clinic
  belongs_to :doctor

  validate :time_range
  validate :working_days

  # Just set default end_time, not select end_time via UI
  before_validation :set_default_values
  def set_default_values
    if self.start_time.present?
      self.end_time = self.start_time + 10.minutes
    end
  end

  def time_range
    if start_time and end_time
      errors.add(:start_time, "must be smaller than End time") if (DateTime.parse(start_time.to_s) >= DateTime.parse(end_time.to_s))
    end
  end

  def working_days
    if start_time and end_time
      cur_time = start_time
      while cur_time < end_time do
        day_of_week = cur_time.strftime("%A")
        if clinic.present? and clinic.not_opening_days.present? and clinic.not_opening_days.include?(day_of_week)
          errors.add(:clinic, "will not open at that time")
        end
        #if doctor.present? and doctor.not_working_days.present? and doctor.not_working_days.include?(day_of_week)
        #  errors.add(:doctor, "will not work at that time")
        #end
        cur_time = cur_time + 1.day
      end
    end
  end

end
