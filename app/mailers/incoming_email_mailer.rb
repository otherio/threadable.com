class IncomingEmailMailer < Covered::Mailer

  def message_held_notice incoming_email
    @incoming_email = incoming_email
    @project = incoming_email.project

    auto_response_mail(
      :'from'     => "Covered message held <#{covered.support_email_address('message-held')}>",
      :'Reply-To' => "Covered message held <#{covered.support_email_address('message-held')}>",
      :'subject'  => "[message held] #{@incoming_email.subject}",
    )
  end

  def message_rejected_notice incoming_email
    @incoming_email = incoming_email
    @project = incoming_email.project

    auto_response_mail(
      :'from'     => "Covered message rejected <#{covered.support_email_address('message-rejected')}>",
      :'Reply-To' => "Covered message rejected <#{covered.support_email_address('message-rejected')}>",
      :'subject'  => "[message rejected] #{@incoming_email.subject}",
    )
  end

  def message_accepted_notice incoming_email
    @incoming_email = incoming_email
    @project = incoming_email.project

    auto_response_mail(
      :'from'     => "Covered message accepted <#{covered.support_email_address('message-accepted')}>",
      :'Reply-To' => "Covered message accepted <#{covered.support_email_address('message-accepted')}>",
      :'subject'  => "[message accepted] #{@incoming_email.subject}",
    )
  end

  private

  def auto_response_mail options={}
    to = @incoming_email.mail_message.return_path || @incoming_email.envelope_from
    message = mail({
      :css              => 'email',
      :'auto-submitted' => 'auto-replied',
      :'to'             => to,
      :'In-Reply-To'    => @incoming_email.message_id,
      :'References'     => [@incoming_email.message_id],
      :'List-ID'        => @project.formatted_list_id,
      :'List-Archive'   => "<#{project_conversations_url(@project)}>",
      :'List-Post'      => "<mailto:#{@project.email_address}>, <#{new_project_conversation_url(@project)}>"
    }.merge(options))

    message.smtp_envelope_from = "no-reply-auto@#{covered.email_host}"
    message
  end

end
