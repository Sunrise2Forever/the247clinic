class VideoSessionSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :symptom, :doctor_id, :start_time, :finish_time, :status, 
    :user_name, :doctor_name, :notes, :diagnosis, :photos

  has_many :photos

  def user_name
  	object.user.try(:name)
	end

	def doctor_name
		object.doctor.try(:name)
	end
end
