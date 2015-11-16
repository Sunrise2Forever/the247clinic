class VideoSession < ActiveRecord::Base
  validates_presence_of :symptom
  belongs_to :user
  scope :pending, -> { where(status: :pending) }
  scope :started, -> { where(status: :started) }
end
