class VideoSessionSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :symptom, :doctor_id, :start_time, :finish_time, :status
end
