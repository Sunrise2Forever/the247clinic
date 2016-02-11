class CallBackSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :doctor_id, :scheduled_time
end
