class EmailProcessor

  class MailgunRequestToEmail < Incoming::Strategies::Mailgun
    default_options[:stripped] = true
    setup :api_key => Multify.config('mailgun')['key']
  end

  def self.process_request(request)
    strategy = MailgunRequestToEmail.new(request)
    strategy.authenticate or return false
    email = strategy.message
    ProcessEmailWorker.enqueue(email.to_s)
  end

  def self.process_email(email)
    new(email).dispatch!
  end

  def initialize(email)
    @email = Mail.read_from_string(email.to_s)
  end

  attr_reader :email

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
      body: email.text_part.body.to_s,
    )
  end

end
