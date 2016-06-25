class CallBackSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :doctor_id, :scheduled_time, :user_name, :doctor_name, :startable

  def user_name
    object.user.try(:name)
  end

  def doctor_name
    object.doctor.try(:name)
  end

  def startable
    object.scheduled_time.present? and object.scheduled_time <= Time.now
  end

end
