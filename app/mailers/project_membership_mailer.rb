class ProjectMembershipMailer < Covered::Mailer

  def join_notice(options) #project_membership, adder, message)
    covered.signed_in!
    @adder     = covered.current_user
    @recipient = Covered::User.find options[:recipient_id]
    @project   = Covered::Project.find options[:project_id]
    @message   = options[:message] || ''


    @project_membership       = @project.project_memberships.where(user: @recipient).first!
    @subject                  = "You've been added to #{@project.name}"
    @project_url              = project_url(@project)
    user_setup_token          = UserSetupToken.encrypt(@recipient.id, project_path(@project))
    @recipient_setup_url      = setup_users_url(user_setup_token)
    project_unsubscribe_token = ProjectUnsubscribeToken.encrypt(@project_membership.id)
    @project_unsubscribe_url  = project_unsubscribe_url(@project, project_unsubscribe_token)

    mail(
      to:      @recipient.formatted_email_address,
      from:    @adder.formatted_email_address,
      subject: @subject,
    )
  end

  def unsubscribe_notice(options)
    @recipient = Covered::User.find options[:recipient_id]
    @project   = Covered::Project.find options[:project_id]

    @project_membership        = @project.project_memberships.where(user: @recipient).first!
    @subject                   = "You've been unsubscribed from #{@project.name}"
    @project_resubscribe_token = ProjectResubscribeToken.encrypt(@project_membership.id)
    @project_resubscribe_url   = project_resubscribe_url(@project, @project_resubscribe_token)
    mail(
      to:      @recipient.formatted_email_address,
      from:    @project.formatted_email_address,
      subject: @subject,
    )
  end

end
