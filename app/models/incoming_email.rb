class IncomingEmail < ActiveRecord::Base

  serialize :params, IncomingEmail::Params

  class MailgunRequestToEmail < ::Incoming::Strategies::Mailgun
    setup :api_key => Covered.config('mailgun')['key']
  end

  def recipient_email_address
    params["recipient"]
  end

  def sender_email_address
    params["sender"]
  end

  def from_email_address
    params["from"]
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


  delegate *%w{header attachments}, to: :mail_message

  def mail_message
    @mail_message ||= MailgunRequestToEmail.new(self).message
  end

end
