class ConversationMailer < ActionMailer::Base

  def conversation_message(params)
    recipient, sender, message, parent = params[:recipient], params[:sender], params[:message], params[:parent_message]

    mail(
      to: "\"#{recipient['name']}\" <#{recipient['email']}>",
      subject: message['subject'],
      from: "\"#{sender['name']}\" <#{sender['email']}>",
      body: message['body'],
      'Reply-To' => params[:reply_to],
      'Message-ID' => message['message_id_header'],
      'In-Reply-To' => parent ? parent['message_id_header'] : nil,
      'References' => parent ? [parent['references_header'], parent['message_id_header']].join(' ') : nil
    )
  end
end


