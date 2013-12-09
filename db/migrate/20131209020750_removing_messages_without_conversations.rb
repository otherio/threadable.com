class RemovingMessagesWithoutConversations < ActiveRecord::Migration
  def up
    Message.joins('LEFT JOIN conversations ON messages.conversation_id = conversations.id WHERE conversations.id IS NULL').delete_all
    EmailAddress.joins('LEFT JOIN users ON email_addresses.user_id = users.id WHERE users.id IS NULL').delete_all
  end

  def down
  end
end
