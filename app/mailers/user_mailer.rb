class UserMailer < ActionMailer::Base

  def unsubscribe_notice(options)
    @project, @user, @host, @port = options.values_at(:project, :user, :host, :port)
    url_options.merge! options.slice()

    subscribe_token = UnsubscribeToken.encrypt(@project.id, @user.id)
    @subscribe_url = project_subscribe_url(@project, subscribe_token, host: @host, port: @port)

    mail(
      to: @user.formatted_email_address,
      from: @project.formatted_email_address,
      subject: "You've been unsubscribed from #{@project.name}",
    )
  end

end
