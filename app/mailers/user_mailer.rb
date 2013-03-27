class UserMailer < ActionMailer::Base

  def unsubscribe_notice(options)
    @options = options
    @sender = options[:project].formatted_email_address
    @subject = "You've been unsubscribed from #{options[:project].name}"
    send_notice
  end

  def invite_notice(options)
    @options = options
    @sender = options[:sender].formatted_email_address
    @subject = "You're invited to #{options[:project].name}"
    @invite_message = options[:invite_message]
    send_notice
  end

  private

  def send_notice
    @project, @user, @host, @port = @options.values_at(:project, :user, :host, :port)
    url_options.merge! @options.slice()

    subscribe_token = UnsubscribeToken.encrypt(@project.id, @user.id)
    @subscribe_url = project_subscribe_url(@project, subscribe_token, host: @host, port: @port)

    mail(
      to: @user.formatted_email_address,
      from: @sender,
      subject: @subject
    )
  end

end
