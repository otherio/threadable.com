class AddConversationsFollowersTable < ActiveRecord::Migration
  def change
    create_table "conversations_followers", id: false, force: true do |t|
      t.integer "conversation_id"
      t.integer "user_id"
    end

    add_index "conversations_followers", ["conversation_id", "user_id"], unique: true
    add_index "conversations_followers", ["conversation_id"]

    add_column :conversations, :follower_ids_cache, :text, after: :muter_ids_cache
  end
end
