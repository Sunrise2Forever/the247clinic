class AddPresenceTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :presence_token, :string
  end
end
