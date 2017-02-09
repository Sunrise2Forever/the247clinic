class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.integer :doctor_id
      t.string :title
      t.string :details
      t.boolean :done

      t.timestamps null: false
    end
  end
end
