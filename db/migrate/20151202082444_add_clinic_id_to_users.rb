class AddClinicIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :clinic_id, :integer
  end
end
