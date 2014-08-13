# Encoding: UTF-8
require 'prepare_email_subject'

class SummaryMailer < Threadable::Mailer
  include Roadie::Rails::Automatic
  include ActionView::Helpers::TextHelper

  add_template_helper ConversationMailerHelper

  def message_summary(organization, recipient, conversations, time)
    @organization = organization
    @recipient = recipient
    @conversations = conversations
    @formatted_date = time.strftime('%a, %b %-d')

    @new_count = {}
    conversations.sort{|a,b| b.last_message_at <=> a.last_message_at}.each do |conversation|
      @new_count[conversation.id] = conversation.messages.count_for_date(time)
    end

    @check_url = "https://s3.amazonaws.com/multify-production/check%402x.png"
    @bubble_url = "https://s3.amazonaws.com/multify-production/bubble%402x.png"

    total_new = 0
    @new_count.values.each { |count| total_new += count }
    @message_count_summary = "#{pluralize(total_new, 'new message')} in #{pluralize(@conversations.count, 'conversation')}"
    subject = "[#{organization.subject_tag}] Summary for #{@formatted_date}: #{@message_count_summary}"

    unsubscribe_token = OrganizationUnsubscribeToken.encrypt(@organization.id, @recipient.id)
    @unsubscribe_url = organization_unsubscribe_url(@organization.slug, unsubscribe_token)

    email = mail(
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
