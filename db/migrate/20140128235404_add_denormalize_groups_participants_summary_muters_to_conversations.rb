class AddDenormalizeGroupsParticipantsSummaryMutersToConversations < ActiveRecord::Migration
  def up
    add_column :conversations, :group_ids_cache, :string
    add_column :conversations, :message_summary_cache, :string
    add_column :conversations, :participant_names_cache, :string
    add_column :conversations, :muter_ids_cache, :string

    Conversation.find_in_batches do |conversations|
      conversations.each do |conversation_record|
        cache_participant_names conversation_record
        cache_group_ids conversation_record
        cache_message_summary conversation_record
        puts conversation_record.slug
      end
    end
  end

  def down
    remove_column :conversations, :group_ids_cache
    remove_column :conversations, :message_summary_cache
    remove_column :conversations, :participant_names_cache
    remove_column :conversations, :muter_ids_cache
  end

  def cache_participant_names conversation_record
    messages = conversation_record.messages.all
    creator = conversation_record.creator
    names = messages.map do |message|
      case
      when message.creator.present?
        message.creator.name.split(/\s+/).first
      else
        ExtractNamesFromEmailAddresses.call([message.from]).first
      end
    end.compact.uniq
    names ||= creator.present? ? [creator.name.split(/\s+/).first] : []
    conversation_record.update_attribute(:participant_names_cache, names)
  end

  def cache_group_ids conversation_record
    conversation_record.update_attribute(:group_ids_cache, conversation_record.groups.all.map(&:id))
  end

  def cache_message_summary conversation_record
    summary = conversation_record.messages.order('created_at DESC').first.try(:body_plain).try(:[], 0..50)
    conversation_record.update_attribute(:message_summary_cache, summary)
  end

  def cache_muter_ids conversation_record
    conversation_record.update_attribute(:muter_ids_cache, conversation_record.muters.map(&:id))
  end
end
