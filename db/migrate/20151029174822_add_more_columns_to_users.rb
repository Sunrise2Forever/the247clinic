class AddMoreColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :address1, :string
    add_column :users, :address2, :string
    add_column :users, :city, :string
    add_column :users, :country, :string
    add_column :users, :provincestate, :string
    add_column :users, :zipcode, :string
    add_column :users, :phone, :string
    add_column :users, :gender, :string
    add_column :users, :birthdate, :date
  end
end
