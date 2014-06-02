class ChangeConversationCachesToText < ActiveRecord::Migration
  def change
    change_column :conversations, :message_summary_cache, :text
    change_column :conversations, :participant_names_cache, :text
    change_column :conversations, :muter_ids_cache, :text
  end
end
