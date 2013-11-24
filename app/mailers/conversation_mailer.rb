# Encoding: UTF-8

class ConversationMailer < Covered::Mailer

  add_template_helper EmailHelper

  def conversation_message(project, message, recipient)
    @project, @message, @recipient = project, message, recipient
    @conversation = @message.conversation
    @task = @conversation if @conversation.task?

    subject_tag = @project.subject_tag
    buffer_length = 80 - @message.body_plain.length
    buffer_length = 0 if buffer_length < 0
    @message_summary = "#{@message.body_plain.to_s[0,200]}#{' ' * buffer_length}#{'.' * buffer_length}"

    subject = @message.subject
    subject = "[#{subject_tag}] #{subject}" unless subject.include?("[#{subject_tag}]")
    # add a check mark to the subject if the conversation is a task, and if the subject doesn't already include one
    subject = "✔ #{subject}" if @task && !subject.include?("✔")

    from = @message.creator.present? && @message.creator == @recipient ?
      @project.formatted_email_address : @message.from

    unsubscribe_token = ProjectUnsubscribeToken.encrypt(@project.id, @recipient.id)
    @unsubscribe_url = project_unsubscribe_url(@project.slug, unsubscribe_token)

    @message.attachments.all.each do |attachment|
      attachments[attachment.filename] = {
        :mime_type => attachment.mimetype,
        :content   => attachment.content,
      }
    end

    @message_url = project_conversation_url(@project, @conversation, anchor: "message-#{@message.id}")

    email = mail(
      :css                 => 'email',
      :'from'              => from,
      :'to'                => @project.formatted_email_address,
      :'subject'           => subject,
      :'Reply-To'          => @project.formatted_email_address,
      :'Message-ID'        => @message.message_id_header,
      :'In-Reply-To'       => @message.parent_message.try(:message_id_header),
      :'References'        => @message.references_header,
      :'List-ID'           => @project.formatted_list_id,
      :'List-Archive'      => "<#{project_conversations_url(@project)}>",
      :'List-Unsubscribe'  => "<#{@unsubscribe_url}>",
      :'List-Post'         => "<mailto:#{@project.email_address}>, <#{new_project_conversation_url(@project)}>"
    )

    email.smtp_envelope_from = @project.email_address
    email.smtp_envelope_to = @recipient.email_address

    email
  end

end
