class IncomingEmail < ActiveRecord::Base

  serialize :params, IncomingEmail::Params

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
    mail_message.text_part.body.raw_source
  end

  def html_part
    mail_message.html_part.body.raw_source
  end

  def text_part_stripped
    mail_message_stripped.text_part.body.raw_source
  end

  def html_part_stripped
    mail_message_stripped.html_part.body.raw_source
  end

  def project_email_address_username
    @project_email_address_username ||= to.map do |email_address|
      email_address.scan(/^(.+?)@(.+\.)?covered.io$/).try(:first)
    end.flatten.compact.first
  end

  def project
    @project ||= Project.where(email_address_username: project_email_address_username).first if
      project_email_address_username.present?
  end

  def parent_message
    @parent_message ||= ParentMessageFinder.call(project.id, header)
  end

  def conversation
    parent_message.try(:conversation)
  end

end
