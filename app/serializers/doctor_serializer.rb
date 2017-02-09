class DoctorSerializer < UserSerializer
  attributes :clinic_id, :not_working_days
end
