class AppointmentSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :user_name, :doctor_id, :doctor_name, :clinic_id, :clinic_name, :email, :phone, :start_time, :end_time

  def user_name
    object.user.try(:name) || object.user_name
  end

  def doctor_name
    doctor = object.doctor.try(:name)
  end

  def clinic_name
    clinic = object.clinic.try(:name)
  end
end
