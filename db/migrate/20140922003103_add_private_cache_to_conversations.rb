class AddPrivateCacheToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :private_cache, :boolean, null: false, default: false
    add_index :conversations, [:private_cache]
  end
end
