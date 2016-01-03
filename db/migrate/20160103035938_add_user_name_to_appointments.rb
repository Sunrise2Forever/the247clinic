class AddUserNameToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :user_name, :string
  end
end
