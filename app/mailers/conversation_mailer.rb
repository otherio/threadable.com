# Encoding: UTF-8

class ConversationMailer < ActionMailer::Base

  add_template_helper EmailHelper

  def conversation_message(message, project_membership)
    if message.creator.nil?
      raise "why does this message not have a creator? #{@message.inspect}"
    end

    @message, @project_membership = message, project_membership
    @recipient = @project_membership.user
    @project = @message.project
    @project_membership = @project.project_memberships.where(user: @recipient).first!
    @conversation = @message.conversation
    subject_tag = @message.project.subject_tag

    subject = @message.subject
    subject = "[#{subject_tag}] #{subject}" unless subject.include?("[#{subject_tag}]")
    # add a check mark to the subject if the conversation is a task, and if the subject doesn't already include one
    subject = "✔ #{subject}" if @message.conversation.task? && !subject.include?("✔")

    from = @message.creator == @recipient ?
      @message.project.formatted_email_address :
      @message.creator.formatted_email_address

    unsubscribe_token = ProjectUnsubscribeToken.encrypt(@project_membership.id)
    @unsubscribe_url = project_unsubscribe_url(@message.project.slug, unsubscribe_token)

    @message.attachments.each do |attachment|
      attachments[attachment.filename] = {
        :mime_type => attachment.mimetype,
        :content   => attachment.content,
      }
    end

    @message_url = project_conversation_url(@project, @conversation, anchor: "message-#{@message.id}")

    mail(
      :css           => 'email',
      :'to'          => %(#{@recipient.name.inspect} <#{@recipient.email}>),
      :'subject'     => subject,
      :'from'        => from,
      :'Reply-To'    => @message.project.formatted_email_address,
      :'Message-ID'  => @message.message_id_header,
      :'In-Reply-To' => @message.parent_message.try(:message_id_header),
      :'References'  => @message.references_header,
    )
  end

end
