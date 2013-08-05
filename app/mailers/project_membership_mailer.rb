class ProjectMembershipMailer < ActionMailer::Base

  def join_notice(project_membership, adder, message)
    @project_membership = project_membership
    @project = @project_membership.project
    @user    = @project_membership.user
    @adder   = adder
    @message = message
    @subject = "You've been added to #{@project.name}"
    @project_url = project_url(@project)
    user_setup_token = UserSetupToken.encrypt(@user.id, project_path(@project))
    @user_setup_url  = user_setup_url(token: user_setup_token)
    project_unsubscribe_token = ProjectUnsubscribeToken.encrypt(@project_membership.id)
    @project_unsubscribe_url  = project_unsubscribe_url(@project, project_unsubscribe_token)

    mail(
      to:      @user.formatted_email_address,
      from:    @adder.formatted_email_address,
      subject: @subject,
    )
  end

  def unsubscribe_notice(project_membership)
    @project_membership = project_membership
    @project = @project_membership.project
    @user    = @project_membership.user
    @subject = "You've been unsubscribed from #{@project.name}"
    @project_resubscribe_token = ProjectResubscribeToken.encrypt(@project_membership.id)
    @project_resubscribe_url = project_resubscribe_url(@project, @project_resubscribe_token)
    mail(
      to:      @user.formatted_email_address,
      from:    @project.formatted_email_address,
      subject: @subject,
    )
  end

end
