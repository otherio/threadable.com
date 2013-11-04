class Covered::IncomingEmail < ActiveRecord::Base

  serialize :params, Covered::IncomingEmail::Params

  class MailgunRequestToEmail < Incoming::Strategies::Mailgun
    setup :api_key => Covered.config('mailgun')['key']
  end

  class MailgunRequestToEmailStripped < Incoming::Strategies::Mailgun
    option :stripped, true
    setup :api_key => Covered.config('mailgun')['key']
  end

  def mail_message
    @mail_message ||= MailgunRequestToEmail.new(self).message
  end

  def mail_message_stripped
    @mail_message_stripped ||= MailgunRequestToEmailStripped.new(self).message
  end

  delegate *%w{
    attachments
    to
    from
    header
    subject
  }, to: :mail_message

  def text_part
    get_raw_source :text
  end

  def html_part
    get_raw_source :html
  end

  def text_part_stripped
    get_raw_source :text, stripped: true
  end

  def html_part_stripped
    get_raw_source :html, stripped: true
  end

  def project_email_address_username
    @project_email_address_username ||= to.map do |email_address|
      email_address.scan(/^(.+?)@(.+\.)?covered.io$/).try(:first)
    end.flatten.compact.first
  end

  def project
    @project ||= Covered::Project.where(email_address_username: project_email_address_username).first if
      project_email_address_username.present?
  end

  def parent_message
    @parent_message ||= ParentMessageFinder.call(project_id: project.id, headers: header)
  end

  def conversation
    parent_message.try(:conversation)
  end

  def conversation_message?
    true
  end

  private

  def get_raw_source content_type, stripped: false
    message = stripped ? mail_message_stripped : mail_message
    part = message.public_send("#{content_type}_part")
    body = (part || message).try(:body)
    body.try(:raw_source) || ""
  end

end
