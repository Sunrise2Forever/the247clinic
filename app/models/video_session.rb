class VideoSession < ActiveRecord::Base
  validates_presence_of :symptom
  belongs_to :user
  belongs_to :doctor, class_name: 'User'

  scope :pending, -> { where(status: :pending) }
  scope :started, -> { where(status: :started) }
end
