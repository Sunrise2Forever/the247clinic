class Csr < User
  default_scope { where(user_type: 'csr') }
end
