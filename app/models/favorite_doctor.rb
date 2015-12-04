class FavoriteDoctor < ActiveRecord::Base
  validates_presence_of :user_id, :doctor_id
  belongs_to :user
  belongs_to :doctor
end
