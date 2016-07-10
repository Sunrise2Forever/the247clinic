class WorkingScheduleSerializer < ActiveModel::Serializer
  attributes :id, :scheduled_day_of_week, :scheduled_date, :start_time, :end_time, :weekly
  has_one :user
end
