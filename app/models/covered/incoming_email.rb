class Covered::IncomingEmail < Covered::Model

  autoload :Process
  autoload :Creator
  autoload :Attachments

  self.model_name = ::IncomingEmail.model_name

  def initialize covered, incoming_email_record
    @covered, @incoming_email_record = covered, incoming_email_record
  end
  attr_reader :covered, :incoming_email_record

  delegate *%w{
    id
    to_param
    params
    processed?
    failed?
    creator_id
    creator_id=
    project_id
    project_id=
    conversation_id
    conversation_id=
    message_id
    message_id=
    parent_message_id
    parent_message_id=
    message_id
    message_id=
    reset!
    created_at
    errors
    persisted?
  }, to: :incoming_email_record

  def creator
    Creator.new(self) if creator_id
  end

  def attachments
    Attachments.new(self)
  end

  def project
    return unless project_id
    @project ||= Covered::Project.new(covered, incoming_email_record.project)
  end

  def conversation
    return unless conversation_id
    @conversation ||= Covered::Conversation.new(covered, incoming_email_record.conversation)
  end

  def message
    return unless message_id
    @message ||= Covered::Message.new(covered, incoming_email_record.message)
  end

  def parent_message
    return unless parent_message_id
    @parent_message ||= Covered::Message.new(covered, incoming_email_record.parent_message)
  end

  def reply?
    !!parent_message_id
  end

  def task?
    conversation.task?
  end

  let :sender_email_address do
    mail_message.sender
  end

  let :from_email_addresses do
    Array(mail_message.from) + [sender_email_address]
  end

  def from_email_address
    params["from"]
  end
  alias_method :from, :from_email_address

  def recipient_email_address
    params["recipient"]
  end

  def subject
    params["subject"]
  end

  def body_plain
    params["body-plain"]
  end

  def body_html
    params["body-html"]
  end

  def stripped_html
    params["stripped-html"]
  end

  def stripped_plain
    params["stripped-text"]
  end

  def message_id_header
    mail_message.header['Message-ID'].to_s
  end

  def references_header
    mail_message.header['References'].to_s
  end

  def date_header
    mail_message.header['Date'].to_s
  end

  def to_header
    message_headers_as_hash['To']
  end

  def cc_header
    message_headers_as_hash['Cc']
  end

  delegate *%w{header multipart?}, to: :mail_message

  class MailgunRequestToEmail < ::Incoming::Strategies::Mailgun
    setup :api_key => Covered.config('mailgun')['key']
  end
  def mail_message
    @mail_message ||= MailgunRequestToEmail.new(self).message
  end

  def message_headers
    @message_headers ||= JSON.parse(params['message-headers'])
  end

  def message_headers_as_hash
    @message_headers_as_hash ||= Hash[message_headers]
  end

  def process!
    Process.call(self)
  end

  def inspect
    details = {
      id:              id,
      processed:       processed?,
      failed:          failed?,
      from:            from,
      creator_id:      creator_id,
      project_id:      project_id,
      conversation_id: conversation_id,
      message_id:      message_id,
    }.map{|k,v| "#{k}: #{v.inspect}"}.join(', ')
    %(#<#{self.class} #{details}>)
  end

end
