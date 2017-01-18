class AddNotWorkingDaysToUsers < ActiveRecord::Migration
  def change
    add_column :users, :not_working_days, :string
  end
end
