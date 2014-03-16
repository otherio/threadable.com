class AddExternalIdToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :external_id, :string
    add_index :conversations, [:external_id]
  end
end
