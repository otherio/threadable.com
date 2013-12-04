class Covered::IncomingEmail

  include Let
  extend ActiveSupport::Autoload

  autoload :Creator
  autoload :Attachments

  def self.model_name
    ::IncomingEmail.model_name
  end

  def initialize covered, incoming_email_record
    @covered, @incoming_email_record = covered, incoming_email_record
  end
  attr_reader :covered, :incoming_email_record

  delegate *%w{
    id
    to_param
    params
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
    created_at
  }, to: :incoming_email_record

  def status
    ActiveSupport::StringInquirer.new incoming_email_record.status
  end

  def creator
    Creator.new(self) if creator_id
  end

  def attachments
    Attachments.new(self)
  end

  def project
    return unless project_id
    @project ||= covered.projects.find_by_id(project_id)
  end

  def conversation
    return unless conversation_id
    @conversation ||= covered.conversations.find_by_id(conversation_id)
  end

  def message
    return unless message_id
    @message ||= covered.messages.find_by_id(message_id)
  end

  def parent_message
    return unless parent_message_id
    @parent_message ||= covered.messages.find_by_id(parent_message_id)
  end

  def sender_email_address
    email_address_for mail_message.sender
  end

  def from_email_addresses
    mail_message.from.map do |email_address|
      email_address_for email_address
    end
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

  delegate *%w{header multipart?}, to: :mail_message

  class MailgunRequestToEmail < ::Incoming::Strategies::Mailgun
    setup :api_key => Covered.config('mailgun')['key']
  end
  def mail_message
    @mail_message ||= MailgunRequestToEmail.new(self).message
  end

  def inspect
    %(#<#{self.class} id: #{id.inspect}>)
  end

  private

  def email_address_for email_address
    Covered::EmailAddress.new(covered, ::EmailAddress.where(address: email_address).first_or_initialize)
  end

end
