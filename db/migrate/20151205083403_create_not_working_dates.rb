class CreateNotWorkingDates < ActiveRecord::Migration
  def change
    create_table :not_working_dates do |t|
      t.integer :user_id
      t.datetime :date

      t.timestamps null: false
    end
  end
end
