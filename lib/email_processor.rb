class EmailProcessor

  class MailgunRequestToEmail < Incoming::Strategies::Mailgun
    setup :api_key => Multify.config('mailgun')['key']
  end

  class MailgunRequestToEmailStripped < Incoming::Strategies::Mailgun
    option :stripped, true
    setup :api_key => Multify.config('mailgun')['key']
  end

  def self.process_request(request)
    strategy = MailgunRequestToEmail.new(request)
    Rails.logger.debug("Received email from mailgun")
    Rails.logger.debug(request.params.to_json)

    strategy.authenticate or return false
    email = strategy.message
    email_stripped = MailgunRequestToEmailStripped.new(request).message

    ProcessEmailWorker.enqueue(email.to_s, email_stripped.to_s)
  end

  def self.process_email(email, email_stripped)
    new(email, email_stripped).dispatch!
  end

  def initialize(email, email_stripped)
    @email = Mail.read_from_string(email.to_s)
    @email_stripped = Mail.read_from_string(email_stripped.to_s)
  end

  attr_reader :email

  def dispatch!
    SendConversationMessageWorker.enqueue(message_id: conversation_message.id)
  end

  def multify_project_slug
    @multify_project_slug ||= email.to.map do |email|
      email.scan(/^(.+?)@(.*)multifyapp.com$/).try(:first)
    end.flatten.compact.first
    raise "No project slug" unless @multify_project_slug
    @multify_project_slug
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

  def parent_message
    in_reply_to = email.header['In-Reply-To'].to_s
    return nil unless in_reply_to || email.header['References']
    return @parent_message if @parent_message

    references = email.header['References'].to_s.split(/\s+/)
    references << in_reply_to if in_reply_to && (in_reply_to != references.last)

    # try the simple query with the most likely parent first
    @parent_message = Message.all(
      :joins => {
        :conversation => :project,
      },
      :conditions => {
        :projects => { :id => project.id },
        :messages => { :message_id_header => references.pop },
      },
    ).first

    unless @parent_message
      # not there! fetch all possible matches
      potential_parents = Message.all(
        :joins => {
          :conversation => :project,
        },
        :conditions => {
          :projects => { :id => project.id },
          :messages => { :message_id_header => references },
        },
      )

      references.reverse.each do |reference|
        potential_parents.each do |message|
          return @parent_message = message if message.message_id_header == reference
        end
      end
    end

    @parent_message
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
      body_plain: filter_token(@email.text_part),
      body_html: filter_token(@email.html_part),
      stripped_plain: filter_token(@email_stripped.text_part),
      stripped_html: filter_token(@email_stripped.html_part),
    )
  end

  private

  def filter_token(part)
    part.body.to_s.gsub(%r{(Unsubscribe:.+http.*multifyapp\.com/.*/unsubscribe/)[^/]+$}m, '\1')
  end

end
