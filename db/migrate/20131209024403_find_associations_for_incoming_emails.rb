class FindAssociationsForIncomingEmails < ActiveRecord::Migration
  def up
    IncomingEmail.all.find_each do |incoming_email|
      if message = Message.where(message_id_header: incoming_email.params['Message-Id']).first
        incoming_email.message_id        = message.id
        incoming_email.conversation_id   = message.conversation_id
        incoming_email.organization_id        = message.conversation.organization_id
        incoming_email.parent_message_id = message.parent_message_id
        incoming_email.attachments       = message.attachments
        incoming_email.params.keys.grep(/^attachment/).each do |key|
          incoming_email.params.delete(key)
        end

        incoming_email.processed = true
        incoming_email.failed    = false
      else
        incoming_email.processed = true
        incoming_email.failed    = true
      end
      incoming_email.save!
    end
  end

  def down
  end
end
