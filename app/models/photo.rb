class Photo < ActiveRecord::Base
  belongs_to :video_session
end
