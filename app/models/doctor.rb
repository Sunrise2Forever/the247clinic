class Doctor < User
  default_scope { where(user_type: 'doctor') }
end
