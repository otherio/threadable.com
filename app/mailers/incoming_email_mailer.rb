class IncomingEmailMailer < Threadable::Mailer

  def message_held_notice incoming_email
    @incoming_email = incoming_email
    @organization = incoming_email.organization
    return nil if incoming_auto_reply

    auto_response_mail(
      :'from'     => "Threadable message held <#{threadable.support_email_address('message-held')}>",
      :'Reply-To' => "Threadable message held <#{threadable.support_email_address('message-held')}>",
      :'subject'  => "[message held] #{@incoming_email.subject}",
    )
  end

  def message_rejected_notice incoming_email
    @incoming_email = incoming_email
    @organization = incoming_email.organization
    return nil if incoming_auto_reply

    auto_response_mail(
      :'from'     => "Threadable message rejected <#{threadable.support_email_address('message-rejected')}>",
      :'Reply-To' => "Threadable message rejected <#{threadable.support_email_address('message-rejected')}>",
      :'subject'  => "[message rejected] #{@incoming_email.subject}",
    )
  end

  def message_accepted_notice incoming_email
    @incoming_email = incoming_email
    @organization = incoming_email.organization
    return nil if incoming_auto_reply

    auto_response_mail(
      :'from'     => "Threadable message accepted <#{threadable.support_email_address('message-accepted')}>",
      :'Reply-To' => "Threadable message accepted <#{threadable.support_email_address('message-accepted')}>",
      :'subject'  => "[message accepted] #{@incoming_email.subject}",
    )
  end

  def message_held_owner_notice incoming_email, owner
    @incoming_email = incoming_email
    @organization = incoming_email.organization
    return nil if incoming_auto_reply

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
    message
  end

  def message_bounced_dsn incoming_email
    @incoming_email = incoming_email
    @bounce_error = bounce_error incoming_email.bounce_reason
    return nil if incoming_auto_reply

    message = mail({
      :css                     => 'email',
      :'auto-submitted'        => 'auto-replied',
      :'to'                    => @incoming_email.sender,
      :'from'                  => "Threadable Mail Error <no-reply-auto@#{threadable.email_host}>",
      :'In-Reply-To'           => @incoming_email.message_id,
      :'References'            => [@incoming_email.message_id],
      :'subject'               => "Delivery Status Notification (Failure)",
      :'X-Mailgun-Track'       => 'no',
      :'X-Mailgun-Native-Send' => 'true',
    })

    message.smtp_envelope_from = ''

    reporting_mta_headers = Mail::Header.new
    reporting_mta_headers.fields = [
      "Reporting-MTA: dns;mxa.#{threadable.host}",
      "Arrival-Date: #{Time.now.utc.rfc2822}",
    ]

    recipient_status_headers = Mail::Header.new
    recipient_status_headers.fields = [
      "Final-Recipient: rfc822;#{@incoming_email.recipient}",
      "Original-Recipient: rfc822;#{@incoming_email.recipient}",
      "Action: failed",
      "Status: #{@bounce_error[:status_code]}",
      "Diagnostic-Code: smtp; 550-#{@bounce_error[:status_code]} #{@bounce_error[:error_message]}",
    ]

    message.part content_type: 'message/delivery-status', body: "#{reporting_mta_headers.to_s}\n#{recipient_status_headers.to_s}"

    message_headers = Mail::Header.new

    message_headers.fields = JSON.parse(@incoming_email.params['message-headers']).map do |header_and_value|
      (header, value) = header_and_value
      "#{header}: #{value}"
    end

    message.part content_type: 'message/rfc822', body: "#{message_headers.to_s}\n#{incoming_email.body_plain}"

    message.content_type = "multipart/report; report-type=delivery-status; boundary=#{message.boundary}"
    message
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
    @incoming_email.mail_message.return_path || @incoming_email.sender
  end

  def bounce_error reason
    codes = {
      missing_organization_or_group: {
        status_code:   '5.1.1',
        error_message: 'The threadable organization/group you tried to reach does not exist.'
      },
      blank_message: {
        status_code:   '5.6.0',
        error_message: 'Threadable cannot deliver a blank message with no subject.'
      },
      trashed_conversation: {
        status_code:   '5.6.0',
        error_message: 'You attempted to reply to a deleted conversation. Please remove the conversation from the trash on Threadable before responding.'
      },
    }

    codes[reason]
  end

  def incoming_auto_reply
    sender = @incoming_email.sender
    @incoming_email.auto_submitted == 'auto-replied' || !sender.present? || sender == '<>'
  end
end
