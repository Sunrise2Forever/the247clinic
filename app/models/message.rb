class Message < ActiveRecord::Base
  validates_presence_of :message
  has_many :answers, dependent: :destroy
  belongs_to :user

  scope :started, -> { where(status: :started) }
end
