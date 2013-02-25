class ConversationMailer < ActionMailer::Base

  def conversation_message(recipient, sender, message, parent)
    mail(
      to: "\"#{recipient['name']}\" <#{recipient['email']}>",
      subject: message['subject'],
      from: "\"#{sender['name']}\" <#{sender['email']}>",
      message_id: message['message_id_header'],
      in_reply_to: parent ? parent['message_id_header'] : nil,
      references: parent ? [parent['references_header'], "<#{parent['message_id_header']}>"].join(' ') : nil,
      body: message['body']
    )
  end
end


