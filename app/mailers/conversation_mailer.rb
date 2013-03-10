class ConversationMailer < ActionMailer::Base

  def conversation_message(params)
    recipient, sender, message, parent, project = params[:recipient], params[:sender], params[:message], params[:parent_message], params[:project]

    subject_tag = project['slug'][0..7]

    mail(
      to: "\"#{recipient['name']}\" <#{recipient['email']}>",
      subject: message['subject'].include?("[#{subject_tag}]") ? message['subject'] : "[#{subject_tag}] #{message['subject']}",
      from: "\"#{sender['name']}\" <#{sender['email']}>",
      body: message['body'],
      'Reply-To' => params[:reply_to],
      'Message-ID' => message['message_id_header'],
      'In-Reply-To' => parent ? parent['message_id_header'] : nil,
      'References' => message['references_header']
    )
  end
end
