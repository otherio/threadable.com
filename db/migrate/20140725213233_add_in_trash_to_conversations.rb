class AddInTrashToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :trashed_at, :datetime
    add_index :conversations, [:trashed_at]
  end
end
