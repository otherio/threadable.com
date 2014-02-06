# Encoding: UTF-8
require 'prepare_email_subject'

class SummaryMailer < Threadable::Mailer

  add_template_helper EmailHelper

  def message_summary(organization, recipient, conversations, date)
    @organization = organization
    @recipient = recipient
    @conversations = conversations
    @formatted_date = date.strftime('%a, %b %-d')

    new_count = {}
    conversations.each do |conversation|
      new_count[conversation.id] = conversation.messages.count_for_date(date)
    end

    total_new = 0
    new_count.values.each { |count| total_new += count }

    subject = "[#{organization.subject_tag}] Summary for #{@formatted_date}: #{pluralize(total_new, 'new message')} in #{pluralize(@conversations.count, 'conversation')}"

    unsubscribe_token = OrganizationUnsubscribeToken.encrypt(@organization.id, @recipient.id)
    @unsubscribe_url = organization_unsubscribe_url(@organization.slug, unsubscribe_token)

    email = mail(
      :css                 => 'message_summary',
      :'from'              => organization.formatted_email_address,
      :'to'                => recipient.formatted_email_address,
      :'subject'           => subject,
      :'List-ID'           => organization.list_id,
      :'List-Archive'      => "<#{conversations_url(organization, 'my')}>",
      :'List-Unsubscribe'  => "<#{@unsubscribe_url}>",
      :'List-Post'         => "<mailto:#{organization.email_address}>, <#{compose_conversation_url(organization, 'my')}>"
    )

    email.smtp_envelope_from = @organization.email_address
    email.smtp_envelope_to = @recipient.email_address.to_s

    email


  end
end
