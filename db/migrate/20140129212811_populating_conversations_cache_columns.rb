class PopulatingConversationsCacheColumns < ActiveRecord::Migration
  def up
    Conversation.find_each do |conversation_record|
      cache_participant_names conversation_record
      cache_group_ids conversation_record
      cache_message_summary conversation_record
      conversation_record.valid?
      conversation_record.save!
      puts conversation_record.slug
    end
  end

  def down
  end

  private

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
    conversation_record.participant_names_cache = names
  end

  def cache_group_ids conversation_record
    conversation_record.group_ids_cache = conversation_record.groups.all.map(&:id)
  end

  def cache_message_summary conversation_record
    summary = conversation_record.messages.order('created_at DESC').first.try(:body_plain).try(:[], 0..50)
    conversation_record.message_summary_cache = summary
  end

  def cache_muter_ids conversation_record
    conversation_record.muter_ids_cache = conversation_record.muters.map(&:id)
  end

end
