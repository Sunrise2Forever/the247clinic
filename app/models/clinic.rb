class Clinic < ActiveRecord::Base
  validates_presence_of :name
  has_many :doctors

  def not_opening_days
    if read_attribute(:not_opening_days).is_a?(String)
      read_attribute(:not_opening_days).split(',')
    else
      super
    end
  end

  def not_opening_days=(val)
    if val.is_a?(Array)
      self.not_opening_days = val.join(',')
    else
      super
    end
  end
end
