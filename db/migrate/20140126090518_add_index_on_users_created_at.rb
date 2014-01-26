class AddIndexOnUsersCreatedAt < ActiveRecord::Migration
  def change
    add_index :users, :created_at
  end
end
