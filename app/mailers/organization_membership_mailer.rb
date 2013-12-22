class ProjectMembershipMailer < Covered::Mailer

  def join_notice project, recipient, personal_message=nil
    @adder = covered.current_user
    @project, @recipient, @personal_message = project, recipient, personal_message

    @subject                  = "You've been added to #{@project.name}"
    @project_url              = project_url(@project)
    user_setup_token          = UserSetupToken.encrypt(@recipient.id, project_path(@project))
    @recipient_setup_url      = setup_users_url(user_setup_token)
    project_unsubscribe_token = ProjectUnsubscribeToken.encrypt(@project.id, @recipient.id)
    @project_unsubscribe_url  = project_unsubscribe_url(@project, project_unsubscribe_token)

    mail(
      to:      @recipient.formatted_email_address,
      from:    @adder.formatted_email_address,
      subject: @subject,
    )
  end

  def unsubscribe_notice project, recipient
    @project, @recipient = project, recipient

    project_resubscribe_token = ProjectResubscribeToken.encrypt(@project.id, @recipient.id)
    @project_resubscribe_url   = project_resubscribe_url(@project, project_resubscribe_token)

    mail(
      to:      @recipient.formatted_email_address,
      from:    @project.formatted_email_address,
      subject: "You've been unsubscribed from #{@project.name}",
    )
  end

end
