class CreateFavoriteDoctors < ActiveRecord::Migration
  def change
    create_table :favorite_doctors do |t|
      t.integer :user_id
      t.integer :doctor_id

      t.timestamps null: false
    end
  end
end
