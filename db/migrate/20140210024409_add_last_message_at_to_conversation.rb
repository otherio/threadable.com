class AddLastMessageAtToConversation < ActiveRecord::Migration
  def up
    add_column :conversations, :last_message_at, :datetime, default: Time.now

    ::Conversation.all.find_in_batches do |conversations|
      conversations.each do |conversation|
        messages = conversation.messages
        if messages.count > 0
          puts conversation.subject
          conversation.update_attribute(:last_message_at, messages.last.created_at)
        else
          conversation.update_attribute(:last_message_at, conversation.updated_at)
        end
      end
    end
  end

  def down
    remove_column :conversations, :last_message_at
  end
end
