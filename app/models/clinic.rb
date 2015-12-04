class Clinic < ActiveRecord::Base
  validates_presence_of :name
  has_many :doctors
end
