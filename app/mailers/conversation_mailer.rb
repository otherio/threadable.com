class ConversationMailer < ActionMailer::Base

  def conversation_message(params)
    recipient, sender, message, parent, project, conversation =
      params[:recipient], params[:sender], params[:message], params[:parent_message], params[:project], params[:conversation]

    subject_tag = project['slug'][0..7]

    body = message['body']
    body += "\n_______________________________________________\n"
    body += "View on Multify: #{project_conversation_url(project['slug'], conversation['slug'])}"

    mail(
      to: "\"#{recipient['name']}\" <#{recipient['email']}>",
      subject: message['subject'].include?("[#{subject_tag}]") ? message['subject'] : "[#{subject_tag}] #{message['subject']}",
      from: "\"#{sender['name']}\" <#{sender['email']}>",
      body: body,
      'Reply-To' => params[:reply_to],
      'Message-ID' => message['message_id_header'],
      'In-Reply-To' => parent ? parent['message_id_header'] : nil,
      'References' => message['references_header']
    )
  end
end
