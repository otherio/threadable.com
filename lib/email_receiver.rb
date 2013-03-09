class EmailReceiver < MethodObject.new(:request)

  class MailgunRequestToEmail < Incoming::Strategies::Mailgun
    setup :api_key => Multify.config('mailgun')['key']
  end

  attr_reader :email

  # http://documentation.mailgun.net/user_manual.html#parsed-messages-parameters
  def call
    strategy = MailgunRequestToEmail.new(@request)
    strategy.authenticate or raise "mailgun authentication failed"
    @email = strategy.message
    dispatch!
    conversation_message
  end

  def dispatch!
    MessageDispatch.new(conversation_message).enqueue
  end

  def multify_project_slug
    # this will move to an envelope thing later
    @multify_project_slug ||= email.to.map do |email|
      email.scan(/^(.+?)@multifyapp.com$/).try(:first)
    end.flatten.compact.first
  end

  def from
    email.from.first
  end

  def project
    @project ||= Project.find_by_slug! multify_project_slug
  end

  def user
    @user ||= project.members.find_by_email! from
  end

  def parent_message_id
    @parent_message_id ||= begin
      if email.header['In-Reply-To']
        email.header['In-Reply-To'].to_s
      elsif email.header['References']
        email.header['References'].to_s.split(/\s+/).last
      end
    end
  end

  def parent_message
    return nil unless parent_message_id.present?
    @parent_message ||= Message.all(
      :joins => {
        :conversation => :project,
      },
      :conditions => {
        :projects => { :id => project.id },
        :messages => { :message_id_header => parent_message_id },
      },
    ).first
  end

  def conversation
    @conversation ||= if parent_message
      parent_message.conversation
    else
      project.conversations.create(
        subject: email.subject,
        creator: user
      )
    end
  end

  def conversation_message
    @conversation_message ||= conversation.messages.create(
      message_id_header: email.header['Message-ID'].to_s,
      subject: email.subject,
      parent_message: parent_message,
      user: user,
      from: from,
      body: email.html_part ? email.html_part.body.to_s : email.body.to_s,
    )
  end

end
