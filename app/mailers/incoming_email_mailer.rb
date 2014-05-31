class IncomingEmailMailer < Threadable::Mailer

  def message_held_notice incoming_email
    @incoming_email = incoming_email
    @organization = incoming_email.organization

    auto_response_mail(
      :'from'     => "Threadable message held <#{threadable.support_email_address('message-held')}>",
      :'Reply-To' => "Threadable message held <#{threadable.support_email_address('message-held')}>",
      :'subject'  => "[message held] #{@incoming_email.subject}",
    )
  end

  def message_rejected_notice incoming_email
    @incoming_email = incoming_email
    @organization = incoming_email.organization

    auto_response_mail(
      :'from'     => "Threadable message rejected <#{threadable.support_email_address('message-rejected')}>",
      :'Reply-To' => "Threadable message rejected <#{threadable.support_email_address('message-rejected')}>",
      :'subject'  => "[message rejected] #{@incoming_email.subject}",
    )
  end

  def message_accepted_notice incoming_email
    @incoming_email = incoming_email
    @organization = incoming_email.organization

    auto_response_mail(
      :'from'     => "Threadable message accepted <#{threadable.support_email_address('message-accepted')}>",
      :'Reply-To' => "Threadable message accepted <#{threadable.support_email_address('message-accepted')}>",
      :'subject'  => "[message accepted] #{@incoming_email.subject}",
    )
  end

  def message_held_owner_notice incoming_email, owner
    @incoming_email = incoming_email
    @organization = incoming_email.organization

    message = mail({
      :css              => 'email',
      :'auto-submitted' => 'auto-replied',
      :'to'             => owner.email_address,
      :'from'           => "Threadable message held <#{threadable.support_email_address('message-held')}>",
      :'Reply-To'       => "Threadable message held <#{threadable.support_email_address('message-held')}>",
      :'In-Reply-To'    => @incoming_email.message_id,
      :'References'     => [@incoming_email.message_id],
      :'subject'        => "[message held, action required] #{@incoming_email.subject}",
      :'List-ID'        => @organization.list_id,
      :'List-Archive'   => "<#{conversations_url(@organization,'my')}>",
      :'List-Post'      => "<mailto:#{@organization.email_address}>, <#{compose_conversation_url(@organization, 'my')}>"
    })

    message.smtp_envelope_from = "no-reply-auto@#{threadable.email_host}"
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
      :'List-ID'        => @organization.list_id,
      :'List-Archive'   => "<#{conversations_url(@organization,'my')}>",
      :'List-Post'      => "<mailto:#{@organization.email_address}>, <#{compose_conversation_url(@organization, 'my')}>"
    }.merge(options))

    message.smtp_envelope_from = "no-reply-auto@#{threadable.email_host}"
    message
  end

end
