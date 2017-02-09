class AddNotOpeningDaysToClinics < ActiveRecord::Migration
  def change
    add_column :clinics, :not_opening_days, :string
  end
end
