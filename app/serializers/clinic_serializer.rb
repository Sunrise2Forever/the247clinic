class ClinicSerializer < ActiveModel::Serializer
  attributes :id, :name, :not_opening_days
end
