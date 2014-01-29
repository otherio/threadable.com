require 'debugger'

class AddDenormalizeGroupsParticipantsSummaryMutersToConversations < ActiveRecord::Migration
  def up
    add_column :conversations, :group_ids_cache, :string
    add_column :conversations, :message_summary_cache, :string
    add_column :conversations, :participant_names_cache, :string
    add_column :conversations, :muter_ids_cache, :string
  end

  def down
    remove_column :conversations, :group_ids_cache
    remove_column :conversations, :message_summary_cache
    remove_column :conversations, :participant_names_cache
    remove_column :conversations, :muter_ids_cache
  end
end
