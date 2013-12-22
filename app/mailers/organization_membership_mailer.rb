class OrganizationMembershipMailer < Covered::Mailer

  def join_notice organization, recipient, personal_message=nil
    @adder = covered.current_user
    @organization, @recipient, @personal_message = organization, recipient, personal_message

    @subject                  = "You've been added to #{@organization.name}"
    @organization_url              = organization_url(@organization)
    user_setup_token          = UserSetupToken.encrypt(@recipient.id, organization_path(@organization))
    @recipient_setup_url      = setup_users_url(user_setup_token)
    organization_unsubscribe_token = OrganizationUnsubscribeToken.encrypt(@organization.id, @recipient.id)
    @organization_unsubscribe_url  = organization_unsubscribe_url(@organization, organization_unsubscribe_token)

    mail(
      to:      @recipient.formatted_email_address,
      from:    @adder.formatted_email_address,
      subject: @subject,
    )
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

end
