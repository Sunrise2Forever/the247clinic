class CreateWorkingSchedules < ActiveRecord::Migration
  def change
    create_table :working_schedules do |t|
      t.references :user, index: true, foreign_key: true
      t.string :scheduled_day_of_week
      t.date :scheduled_date
      t.time :start_time
      t.time :end_time
      t.boolean :weekly

      t.timestamps null: false
    end
  end
end
