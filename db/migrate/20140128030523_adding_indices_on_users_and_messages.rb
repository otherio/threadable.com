class AddingIndicesOnUsersAndMessages < ActiveRecord::Migration
  def up
    add_index    :users, :name
    add_index    :messages, [:conversation_id, :user_id]
    add_index    :messages, [:created_at]
    remove_index :messages, [:conversation_id]
  end

  def down
    remove_index :users, :name
    remove_index :messages, [:conversation_id, :user_id]
    remove_index :messages, [:created_at]
    add_index    :messages, [:conversation_id]
  end
end
