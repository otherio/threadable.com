class MembershipMailer < Threadable::Mailer

  add_template_helper EmailHelper

  def join_notice organization, recipient, personal_message=nil
    @adder = threadable.current_user
    @organization, @recipient, @personal_message = organization, recipient, personal_message

    @subject                  = "You've been added to #{@organization.name}"
    setup_join_notice

    mail_params = {
      to:      @recipient.formatted_email_address,
      subject: @subject,
    }.merge(dmarc_aware_headers(@adder.formatted_email_address))

    email = mail(mail_params)
    email.smtp_envelope_from = organization.email_address
    email
  end

  def self_join_notice organization, recipient
    @organization, @recipient = organization, recipient

    @subject                  = "You've added yourself to #{@organization.name}"
    setup_join_notice

    mail_params = {
      to:       @recipient.formatted_email_address,
      subject:  @subject,
      from:     @organization.formatted_email_address,
      reply_to: "Threadable <#{threadable.support_email_address('join')}>",
    }

    email = mail(mail_params)
    email.smtp_envelope_from = organization.email_address
    email
  end

  def self_join_notice_confirm organization, recipient
    @organization, @recipient = organization, recipient

    @subject                  = "Confirm your membership in #{@organization.name}"
    setup_join_notice

    mail_params = {
      to:       @recipient.formatted_email_address,
      subject:  @subject,
      from:     @organization.formatted_email_address,
      reply_to: "Threadable <#{threadable.support_email_address('join')}>",
    }

    email = mail(mail_params)
    email.smtp_envelope_from = organization.email_address
    email
  end

  def invitation organization, recipient
    @adder = threadable.current_user
    @organization, @recipient, @personal_message = organization, recipient

    @subject                  = "You've been invited to #{@organization.name}"
    setup_join_notice

    mail_params = {
      to:      @recipient.formatted_email_address,
      subject: @subject,
    }.merge(dmarc_aware_headers(@adder.formatted_email_address))

    email = mail(mail_params)
    email.smtp_envelope_from = organization.email_address
    email
  end

  def unsubscribe_notice organization, recipient
    @organization, @recipient = organization, recipient

    organization_resubscribe_token = OrganizationResubscribeToken.encrypt(@organization.id, @recipient.id)
    @organization_resubscribe_url   = organization_resubscribe_url(@organization, organization_resubscribe_token)

    mail(
      to:      @recipient.formatted_email_address,
      from:    @organization.formatted_email_address,
      subject: "You've been unsubscribed from #{@organization.name}",
    )
  end

  def added_to_group_notice organization, group, sender, recipient
    @organization, @group, @sender, @recipient = organization, group, sender, recipient

    mail_params = {
      to:      @recipient.formatted_email_address,
      subject: "I added you to #{group.name} on #{organization.name}",
    }.merge(dmarc_aware_headers(@sender.formatted_email_address))

    email = mail(mail_params)
    email.smtp_envelope_from = organization.email_address
    email
  end

  def removed_from_group_notice organization, group, sender, recipient
    @organization, @group, @sender, @recipient = organization, group, sender, recipient

    mail_params = {
      to:      @recipient.formatted_email_address,
      subject: "I removed you from #{group.name} on #{organization.name}",
    }.merge(dmarc_aware_headers(@sender.formatted_email_address))

    email = mail(mail_params)
    email.smtp_envelope_from = organization.email_address
    email
  end

  private

  def dmarc_aware_headers email_address
    address = begin
      Mail::Address.new(email_address)
    rescue Mail::Field::ParseError
      Mail::Address.new(email_address.to_ascii.gsub(/[:,]/, ''))
    end

    return { from: email_address } if VerifyDmarc.call(address)

    {
      :from       => "#{address.name || address.local} via Threadable <placeholder@#{threadable.email_host}>",
      :'Reply-To' => email_address
    }
  end

  def setup_join_notice
    @organization_url         = organization_url(@organization)
    user_setup_token          = UserSetupToken.encrypt(@recipient.id, @organization.id)
    @recipient_setup_url      = setup_users_url(user_setup_token)
    organization_unsubscribe_token = OrganizationUnsubscribeToken.encrypt(@organization.id, @recipient.id)
    @organization_unsubscribe_url  = organization_unsubscribe_url(@organization, organization_unsubscribe_token)
  end

end
