class FavoriteClinic < ActiveRecord::Base
  validates_presence_of :user_id, :clinic_id
  belongs_to :user
  belongs_to :clinic
end
