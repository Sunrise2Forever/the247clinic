class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :phone, :mspnum, :birthdate, :authentication_token
end
