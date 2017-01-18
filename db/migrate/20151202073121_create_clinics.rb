class CreateClinics < ActiveRecord::Migration
  def change
    create_table :clinics do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
