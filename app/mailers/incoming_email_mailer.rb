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

  def message_bounced_notice incoming_email
    @incoming_email = incoming_email

    message = mail({
      :css              => 'email',
      :'auto-submitted' => 'auto-replied',
      :'to'             => return_path,
      :'from'           => "Threadable Mail Error <no-reply-auto@#{threadable.email_host}>",
      :'In-Reply-To'    => @incoming_email.message_id,
      :'References'     => [@incoming_email.message_id],
      :'subject'        => "Delivery Status Notification (Failure)",
    })

    message.smtp_envelope_from = "no-reply-auto@#{threadable.email_host}"

    status_headers = Mail::Header.new
    status_headers.fields = [
      "Final-Recipient: rfc822;#{@incoming_email.recipient}",
      "Original-Recipient: rfc822;#{@incoming_email.recipient}",
      "Action: failed",
      "Status: 5.1.1",
      "Remote-MTA: dns;mxa.#{threadable.host}",
      "Diagnostic-Code: smtp; 550-5.1.1 The threadable organization/group you tried to reach does not exist.",
    ]

    message.part content_type: 'message/delivery-status', body: status_headers.to_s

    message_headers = Mail::Header.new

    message_headers.fields = JSON.parse(@incoming_email.params['message-headers']).map do |header_and_value|
      (header, value) = header_and_value
      "#{header}: #{value}"
    end

    message.part content_type: 'message/rfc822', body: message_headers.to_s

    message.content_type = "multipart/report; report-type=delivery-status; boundary=#{message.boundary}"
  end

  private

  def auto_response_mail options={}
    message = mail({
      :css              => 'email',
      :'auto-submitted' => 'auto-replied',
      :'to'             => return_path,
      :'In-Reply-To'    => @incoming_email.message_id,
      :'References'     => [@incoming_email.message_id],
      :'List-ID'        => @organization.list_id,
      :'List-Archive'   => "<#{conversations_url(@organization,'my')}>",
      :'List-Post'      => "<mailto:#{@organization.email_address}>, <#{compose_conversation_url(@organization, 'my')}>"
    }.merge(options))

    message.smtp_envelope_from = "no-reply-auto@#{threadable.email_host}"
    message
  end

  def return_path
    @incoming_email.mail_message.return_path || @incoming_email.envelope_from
  end
end
