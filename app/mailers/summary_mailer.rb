# Encoding: UTF-8
require 'prepare_email_subject'

class SummaryMailer < Threadable::Mailer

  add_template_helper EmailHelper

  def message_summary(organization, recipient, messages)
    binding.pry
  end
end
