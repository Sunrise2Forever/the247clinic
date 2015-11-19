class CallBack < ActiveRecord::Base
  validates_presence_of :user_id
  belongs_to :user
  belongs_to :doctor, class_name: 'User'
end
