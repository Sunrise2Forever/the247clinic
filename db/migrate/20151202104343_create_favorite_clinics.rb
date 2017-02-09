class CreateFavoriteClinics < ActiveRecord::Migration
  def change
    create_table :favorite_clinics do |t|
      t.integer :user_id
      t.integer :clinic_id

      t.timestamps null: false
    end
  end
end
