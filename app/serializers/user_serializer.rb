class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :phone, :mspnum, :birthdate, :user_type, :authentication_token
end
