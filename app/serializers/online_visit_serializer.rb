class OnlineVisitSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :csr_id, :scheduled_time, :user_name, :csr_name, :startable

  def user_name
    object.user.try(:name)
  end

  def csr_name
    object.csr.try(:name)
  end

  def startable
    object.scheduled_time.present? and object.scheduled_time <= Time.now
  end

end
