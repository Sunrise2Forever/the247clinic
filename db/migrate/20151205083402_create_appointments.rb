class CreateAppointments < ActiveRecord::Migration
  def change
    create_table :appointments do |t|
      t.integer :user_id
      t.integer :clinic_id
      t.integer :doctor_id
      t.string :email
      t.string :phone
      t.datetime :start_time
      t.datetime :end_time
      t.string :status

      t.timestamps null: false
    end
  end
end
