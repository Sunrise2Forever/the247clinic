class MessageSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :message, :status
end
