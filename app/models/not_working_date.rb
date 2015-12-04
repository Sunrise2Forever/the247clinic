class NotWorkingDate < ActiveRecord::Base
  validates_presence_of :date
  belongs_to :user
end
