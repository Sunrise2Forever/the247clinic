json.array!(@working_schedules) do |working_schedule|
  json.extract! working_schedule, :id, :user_id, :scheduled_day_of_week, :scheduled_date, :start_time, :end_time, :weekly
  json.url working_schedule_url(working_schedule, format: :json)
end
