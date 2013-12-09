# Encoding: UTF-8

class ConversationMailer < Covered::Mailer

  add_template_helper EmailHelper

  def conversation_message(project, message, recipient)
    @project, @message, @recipient = project, message, recipient
    @conversation = @message.conversation
    @task = @conversation if @conversation.task?

    subject_tag = @project.subject_tag
    buffer_length = 100 - @message.body_plain.length
    buffer_length = 0 if buffer_length < 0
    @message_summary = "#{@message.body_plain.to_s[0,200]}#{' ' * buffer_length}#{'_' * buffer_length}"

    subject = @message.subject

    # add a check mark to the subject if the conversation is a task, and if the subject doesn't already include one
    subject = "✔ #{subject}" if @task && !subject.include?("✔")
    subject = "[#{subject_tag}] #{subject}" unless subject.include?("[#{subject_tag}]")

    from = @message.from || @message.creator.try(:formatted_email_address ) || @project.formatted_email_address
    unsubscribe_token = ProjectUnsubscribeToken.encrypt(@project.id, @recipient.id)
    @unsubscribe_url = project_unsubscribe_url(@project.slug, unsubscribe_token)

    @message.attachments.all.each do |attachment|
      attachments[attachment.filename] = {
        :mime_type => attachment.mimetype,
        :content   => attachment.content,
      }
    end

    @message_url = project_conversation_url(@project, @conversation, anchor: "message-#{@message.id}")

    to = begin
      to_addresses = Mail::AddressList.new(@message.to_header.to_s).addresses
      to_addresses = filter_out_project_members(to_addresses)
      to_addresses.map(&:to_s).join(', ').presence || @project.formatted_email_address
    end

    cc = begin
      cc_addresses = Mail::AddressList.new(@message.cc_header.to_s).addresses
      cc_addresses = filter_out_project_members(cc_addresses)
      cc_addresses.map(&:to_s).join(', ').presence || nil
    end


    email = mail(
      :css                 => 'email',
      :'from'              => from,
      :'to'                => to,
      :'cc'                => cc,
      :'subject'           => subject,
      :'Reply-To'          => @project.formatted_email_address,
      :'Message-ID'        => @message.message_id_header,
      :'References'        => @message.references_header,
      :'Date'              => @message.date_header,
      :'In-Reply-To'       => @message.parent_message.try(:message_id_header),
      :'List-ID'           => @project.formatted_list_id,
      :'List-Archive'      => "<#{project_conversations_url(@project)}>",
      :'List-Unsubscribe'  => "<#{@unsubscribe_url}>",
      :'List-Post'         => "<mailto:#{@project.email_address}>, <#{new_project_conversation_url(@project)}>"
    )

    email.smtp_envelope_from = @project.email_address
    email.smtp_envelope_to = @recipient.email_address

    email
  end

  private

  def project_member_emails_addresses
    @project_member_emails_addresses ||= @project.members.email_addresses
  end

  def filter_out_project_members email_addresses
    email_addresses.select do |email_address|
      project_member_emails_addresses.none? do |member_email_address|
        member_email_address.address == email_address.address
      end
    end
  end

end
